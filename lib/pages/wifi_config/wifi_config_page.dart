import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:http/http.dart' as http;
import '../../utils/wifi_config_manager.dart';

// WiFi连接状态枚举
enum ConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error
}

/// WiFi配置页面
class WiFiConfigPage extends StatefulWidget {
  const WiFiConfigPage({Key? key}) : super(key: key);

  @override
  State<WiFiConfigPage> createState() => _WiFiConfigPageState();
}

class _WiFiConfigPageState extends State<WiFiConfigPage> {
  // WiFi配置管理器
  final _wifiManager = WiFiConfigManager();
  
  // 状态变量
  List<WiFiAccessPoint> _accessPoints = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _showWebView = false;
  String? _selectedSSID;
  String? _errorMsg;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  
  // WebView控制器
  late final WebViewController _webViewController;
  
  // 当前连接的WiFi
  String? _currentConnectedSSID;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化WebView控制器
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            debugPrint('页面加载完成: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView错误: ${error.description}');
            setState(() {
              _errorMsg = '配置页面加载失败: ${error.description}';
              _showWebView = false;
            });
          },
        ),
      );
    
    // 请求所有必要的权限并扫描WiFi
    _requestAllPermissionsAndScan();
    
    // 获取当前连接的WiFi
    _getCurrentWifi();
  }
  
  // 请求所有必要权限并扫描
  Future<void> _requestAllPermissionsAndScan() async {
    setState(() {
      _isScanning = true;
      _errorMsg = null;
    });

    try {
      // 请求位置权限
      final locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        setState(() {
          _errorMsg = '需要位置权限才能扫描WiFi';
          _isScanning = false;
        });
        return;
      }

      // 在Android 12+上，还需要附近设备权限
      if (Platform.isAndroid && await Permission.nearbyWifiDevices.shouldShowRequestRationale) {
        final nearbyDevicesStatus = await Permission.nearbyWifiDevices.request();
        if (!nearbyDevicesStatus.isGranted) {
          setState(() {
            _errorMsg = '需要附近设备权限才能扫描WiFi';
            _isScanning = false;
          });
          return;
        }
      }
      
      // 现在尝试扫描WiFi
      await _scanWiFi();
      
      // 同时刷新当前连接的WiFi
      await _getCurrentWifi();
    } catch (e) {
      debugPrint('权限请求过程出错: $e');
      setState(() {
        _errorMsg = '权限请求过程出错: $e';
        _isScanning = false;
      });
    }
  }
  
  // 获取Android版本号
  Future<int> _getAndroidSdkVersion() async {
    try {
      // 这里我们不能直接获取，返回一个估计值
      // 实际应用中应该通过platform channel获取真实值
      return 31; // 假设是Android 12
    } catch (e) {
      debugPrint('获取Android版本失败: $e');
      return 30; // 假设至少是Android 11
    }
  }
  
  // 显示权限解释对话框
  void _showPermissionExplanationDialog({
    required String title,
    required String content,
    required VoidCallback onOpenSettings,
  }) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            child: const Text('去设置', style: TextStyle(color: Color(0xFF3C8BFF))),
          ),
        ],
      ),
    );
  }
  
  // 打开应用设置
  void _openAppSettings() async {
    try {
      final opened = await openAppSettings();
      if (!opened) {
        debugPrint('无法打开应用设置');
      }
    } catch (e) {
      debugPrint('打开应用设置时出错: $e');
    }
  }
  
  // 扫描WiFi网络
  Future<void> _scanWiFi() async {
    setState(() {
      _isScanning = true;
      _errorMsg = null;
    });

    try {
      // 检查是否可以获取扫描结果
      final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
      debugPrint('WiFi扫描状态: $canGetScannedResults');
      
      // 如果不能获取扫描结果，显示错误
      if (canGetScannedResults != CanGetScannedResults.yes) {
        setState(() {
          _errorMsg = '无法获取WiFi扫描结果: $canGetScannedResults';
          _isScanning = false;
        });
        return;
      }

      // 开始扫描
      final startScan = await WiFiScan.instance.startScan();
      debugPrint('开始扫描: $startScan');

      // 等待扫描完成
      await Future.delayed(const Duration(seconds: 2));

      // 获取扫描结果
      final scanResults = await WiFiScan.instance.getScannedResults();
      
      // 过滤包含xiaoxin或xiaozhi的WiFi网络（不区分大小写）
      final filteredResults = scanResults.where((ap) {
        final ssid = ap.ssid.toLowerCase();
        return ssid.contains('xiaoxin') || ssid.contains('xiaozhi');
      }).toList();
      
      debugPrint('过滤前WiFi数量: ${scanResults.length}, 过滤后WiFi数量: ${filteredResults.length}');
      
      // 去重处理
      final uniqueNetworks = <String, WiFiAccessPoint>{};
      for (var ap in filteredResults) {
        final ssid = ap.ssid;
        // 只保留信号最强的同名网络
        if (ssid.isNotEmpty && (!uniqueNetworks.containsKey(ssid) || 
            uniqueNetworks[ssid]!.level < ap.level)) {
          uniqueNetworks[ssid] = ap;
        }
      }
      
      // 转换为列表并排序
      final sortedNetworks = uniqueNetworks.values.toList();
      
      // 先按照是否是当前连接的网络排序，再按信号强度排序
      sortedNetworks.sort((a, b) {
        // 如果a是当前连接的网络，排在最前面
        if (a.ssid == _currentConnectedSSID) return -1;
        // 如果b是当前连接的网络，排在最前面
        if (b.ssid == _currentConnectedSSID) return 1;
        // 否则按信号强度排序
        return b.level.compareTo(a.level);
      });

      setState(() {
        _accessPoints = sortedNetworks;
        _isScanning = false;
      });
    } catch (e) {
      debugPrint('扫描WiFi出错: $e');
      setState(() {
        _errorMsg = '扫描WiFi出错: $e';
        _isScanning = false;
      });
    }
  }
  
  // 显示WiFi服务对话框
  void _showWifiServiceDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要开启WiFi'),
        content: const Text('请开启WiFi以扫描可用网络'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 打开系统WiFi设置页面
              _openWifiSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
  
  // 打开WiFi设置
  void _openWifiSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('无法打开应用设置: $e');
    }
  }
  
  // 连接到WiFi
  Future<void> _connectToWifi(String ssid) async {
    debugPrint('开始连接WiFi: $ssid');
    setState(() {
      _isConnecting = true;
      _selectedSSID = ssid;
      _errorMsg = null;
    });
    
    try {
      // 检查WiFi是否需要密码
      final needsPassword = _isWifiProtected(ssid);
      debugPrint('WiFi $ssid 是否需要密码: $needsPassword');
      
      // 如果WiFi不需要密码，直接连接
      if (!needsPassword) {
        debugPrint('WiFi不需要密码，直接连接');
        final result = await _wifiManager.connectToWifi(ssid, null);
        debugPrint('WiFi连接结果: $result');
        
        if (result) {
          // 连接成功，加载配置页面
          debugPrint('WiFi连接成功，加载配置页面');
          await _loadConfigPage();
        } else {
          debugPrint('WiFi连接失败');
          setState(() {
            _errorMsg = '无法连接到 $ssid';
            _isConnecting = false;
          });
          // 连接失败后刷新WiFi列表
          _scanWiFi();
        }
        return;
      }
      
      // 如果WiFi需要密码，显示密码输入对话框
      debugPrint('WiFi需要密码，显示密码输入对话框');
      final password = await _showPasswordDialog(ssid);
      debugPrint('用户输入密码: ${password != null ? "已输入" : "已取消"}');
      
      if (password == null) {
        // 用户取消了输入密码
        debugPrint('用户取消了密码输入，中止连接');
        setState(() {
          _isConnecting = false;
        });
        // 用户取消后刷新WiFi列表
        _scanWiFi();
        return;
      }
      
      // 连接到WiFi网络
      debugPrint('开始连接WiFi: $ssid, 密码: 已提供');
      final result = await _wifiManager.connectToWifi(ssid, password);
      debugPrint('WiFi连接结果: $result');
      
      if (result) {
        // 连接成功，加载配置页面
        debugPrint('WiFi连接成功，加载配置页面');
        await _loadConfigPage();
      } else {
        debugPrint('WiFi连接失败');
        setState(() {
          _errorMsg = '无法连接到 $ssid';
          _isConnecting = false;
        });
        // 连接失败后刷新WiFi列表
        _scanWiFi();
      }
    } catch (e) {
      debugPrint('连接WiFi过程中出错: $e');
      setState(() {
        _errorMsg = '连接WiFi时出错: $e';
        _isConnecting = false;
      });
      // 出错时也刷新WiFi列表
      _scanWiFi();
    }
  }
  
  // 判断WiFi是否受保护（需要密码）
  bool _isWifiProtected(String ssid) {
    try {
      // 查找对应的WiFi接入点
      final accessPoint = _accessPoints.firstWhere(
        (ap) => ap.ssid == ssid,
        orElse: () => throw Exception('未找到指定的WiFi网络'),
      );
      
      // 检查安全类型
      final capabilities = accessPoint.capabilities.toLowerCase();
      debugPrint('WiFi $ssid 的安全类型: $capabilities');
      
      // 如果包含这些字符串，说明需要密码
      final needsPassword = capabilities.contains('wpa') || 
             capabilities.contains('wep') || 
             capabilities.contains('psk') ||
             capabilities.contains('wpa2') ||
             capabilities.contains('wpa3');
              
      debugPrint('WiFi $ssid 是否需要密码: $needsPassword');
      return needsPassword;
    } catch (e) {
      debugPrint('判断WiFi是否需要密码时出错: $e');
      // 如果无法确定，默认需要密码更安全
      return true;
    }
  }
  
  // 显示密码输入对话框
  Future<String?> _showPasswordDialog(String ssid) async {
    final passwordController = TextEditingController();
    bool obscureText = true;
    bool isConnecting = false;
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                Center(
                  child: Text(
                    '连接到 $ssid',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 密码输入框
                TextField(
                  controller: passwordController,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入WiFi密码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  enabled: !isConnecting,
                ),
                const SizedBox(height: 24),
                
                // 按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 取消按钮
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isConnecting
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 连接按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isConnecting
                            ? null
                            : () {
                                setState(() {
                                  isConnecting = true;
                                });
                                Navigator.of(context).pop(passwordController.text);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isConnecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('连接'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 加载配置页面
  Future<void> _loadConfigPage() async {
    try {
      // 先更新UI状态，显示已连接
      setState(() {
        _isConnecting = false;
        _connectionStatus = ConnectionStatus.connected;
        _errorMsg = '已连接WiFi，正在打开配置页面...';
      });
      
      // 连接成功后刷新WiFi列表
      _scanWiFi();
      
      // 使用固定的设备IP地址192.168.4.1
      const String deviceIp = '192.168.4.1';
      
      // 直接加载配置页面，不再检测是否存在
      final url = 'http://$deviceIp';
      debugPrint('直接加载配置页面: $url');
      
      // 加载URL到WebView
      await _webViewController.loadRequest(Uri.parse(url));
      
      setState(() {
        _showWebView = true;
        _errorMsg = null;
      });
    } catch (e) {
      debugPrint('加载配置页面时出错: $e');
      setState(() {
        _errorMsg = '加载配置页面时出错: $e';
        _showWebView = false;
      });
      
      // 出错时也刷新WiFi列表
      _scanWiFi();
    }
  }
  
  // 获取当前连接的WiFi
  Future<void> _getCurrentWifi() async {
    try {
      final currentSsid = await _wifiManager.getCurrentWifiSSID();
      setState(() {
        _currentConnectedSSID = currentSsid;
      });
    } catch (e) {
      debugPrint('获取当前WiFi时出错: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi配网 (xiaoxin/xiaozhi)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _requestAllPermissionsAndScan,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    // 显示WebView
    if (_showWebView) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.green[100],
            width: double.infinity,
            child: Text(
              '已连接到 $_selectedSSID，请在下方进行设备配置',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
          // 配置完成按钮
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('配置完成'),
            ),
          ),
        ],
      );
    }

    // 显示主界面（扫描结果或提示）
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(),
          const SizedBox(height: 16),
          _buildNetworkList(),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    // 显示错误信息
    if (_errorMsg != null && _errorMsg!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.red[100],
        width: double.infinity,
        child: Text(
          _errorMsg!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // 扫描状态
    if (_isScanning) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue[100],
        width: double.infinity,
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('正在扫描WiFi网络...'),
          ],
        ),
      );
    }

    // 连接状态
    if (_isConnecting) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.orange[100],
        width: double.infinity,
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('正在连接WiFi...'),
          ],
        ),
      );
    }

    // 默认提示
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      width: double.infinity,
      child: const Text('请选择包含xiaoxin或xiaozhi的WiFi网络'),
    );
  }
  
  // 构建WiFi列表
  Widget _buildNetworkList() {
    return Expanded(
      child: _accessPoints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '未找到符合条件的WiFi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '请确保设备已开启，并且WiFi名称包含xiaoxin或xiaozhi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _requestAllPermissionsAndScan,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新扫描'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _accessPoints.length,
              itemBuilder: (context, index) {
                final ap = _accessPoints[index];
                final ssid = ap.ssid;
                final isProtected = _isWifiProtected(ssid);
                final isCurrentConnected = ssid == _currentConnectedSSID;
                
                // 计算信号强度图标
                IconData signalIcon;
                if (ap.level >= -50) {
                  signalIcon = Icons.signal_wifi_4_bar;
                } else if (ap.level >= -70) {
                  signalIcon = Icons.network_wifi;
                } else {
                  signalIcon = Icons.signal_wifi_0_bar;
                }
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: isCurrentConnected ? Colors.green[50] : null,
                  child: ListTile(
                    leading: Icon(
                      signalIcon,
                      color: isCurrentConnected ? Colors.green : Colors.blue,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ssid,
                            style: TextStyle(
                              fontWeight: isCurrentConnected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        // 只对需要密码的WiFi显示锁图标，但已连接的WiFi不显示
                        if (isProtected && !isCurrentConnected)
                          const Icon(Icons.lock, size: 16, color: Colors.grey),
                      ],
                    ),
                    subtitle: Text('信号强度: ${ap.level} dBm'),
                    trailing: isCurrentConnected 
                        ? null  // 已连接的WiFi不显示任何按钮
                        : ElevatedButton(
                            child: const Text('连接'),
                            onPressed: _isConnecting
                                ? null
                                : () => _connectToWifi(ssid),
                          ),
                  ),
                );
              },
            ),
    );
  }
} 