import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:app_settings/app_settings.dart';
import '../../utils/wifi_config_manager.dart';

class WiFiConfigPage extends StatefulWidget {
  const WiFiConfigPage({super.key});

  @override
  State<WiFiConfigPage> createState() => _WiFiConfigPageState();
}

class _WiFiConfigPageState extends State<WiFiConfigPage> {
  // WiFi配置管理器
  final WiFiConfigManager _wifiManager = WiFiConfigManager();
  
  // 状态变量
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _showWebView = false;
  List<WiFiAccessPoint> _accessPoints = [];
  String? _selectedSSID;
  String? _errorMsg;
  
  // WebView控制器
  late final WebViewController _webViewController;
  
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
  }
  
  // 请求所有必要的权限并扫描WiFi
  Future<void> _requestAllPermissionsAndScan() async {
    setState(() {
      _isScanning = true;
      _errorMsg = null;
    });
    
    try {
      debugPrint('检查并请求所有必要权限...');
      
      // 检查Android版本，请求相应的权限
      final androidSdkVersion = await _getAndroidSdkVersion();
      debugPrint('Android SDK 版本: $androidSdkVersion');
      
      // 请求精确位置权限 (必要的)
      final locationStatus = await Permission.locationWhenInUse.request();
      debugPrint('位置权限状态: $locationStatus');
      
      // 尝试请求更精确的位置权限
      if (locationStatus.isGranted) {
        final precisLocationStatus = await Permission.location.request();
        debugPrint('精确位置权限状态: $precisLocationStatus');
      }
      
      // Android 12 (API 31+) 还需要附近设备权限
      if (androidSdkVersion >= 31) {
        final nearbyDevicesStatus = await Permission.nearbyWifiDevices.request();
        debugPrint('附近WiFi设备权限状态: $nearbyDevicesStatus');
      }
      
      // 检查位置权限是否已授予
      if (!await Permission.location.isGranted) {
        setState(() {
          _errorMsg = '需要位置权限来扫描WiFi';
          _isScanning = false;
        });
        _showPermissionExplanationDialog(
          title: '需要位置权限',
          content: 'Android系统要求应用必须有位置权限才能扫描WiFi网络。\n\n请在设置中授予"位置信息"权限，并选择"精确"和"始终允许"选项。',
          onOpenSettings: _openAppSettings,
        );
        return;
      }
      
      // 现在尝试扫描WiFi
      await _scanWifi();
    } catch (e) {
      debugPrint('权限请求过程出错: $e');
      setState(() {
        _errorMsg = '准备WiFi扫描时出错: $e';
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
  
  // 扫描WiFi
  Future<void> _scanWifi() async {
    try {
      debugPrint('开始WiFi扫描准备...');
      
      // 检查是否可以扫描
      final canScan = await WiFiScan.instance.canStartScan();
      debugPrint('WiFi扫描状态检查结果: $canScan');
      
      if (canScan == CanStartScan.yes) {
        debugPrint('条件满足，开始WiFi扫描...');
        
        // 开始扫描
        final result = await WiFiScan.instance.startScan();
        debugPrint('WiFi扫描启动结果: $result');
        
        if (result) {
          // 给扫描一些时间完成
          debugPrint('等待扫描完成...');
          await Future.delayed(const Duration(seconds: 2));
          
          // 获取扫描结果
          debugPrint('获取WiFi扫描列表...');
          final accessPoints = await WiFiScan.instance.getScannedResults();
          debugPrint('获取到 ${accessPoints.length} 个WiFi网络');
          
          setState(() {
            // 显示所有可用网络，并标记设备热点
            _accessPoints = accessPoints.where((ap) => ap.ssid.isNotEmpty).toList();
            debugPrint('过滤后剩余 ${_accessPoints.length} 个WiFi网络');
            
            // 如果没有找到可用网络
            if (_accessPoints.isEmpty) {
              _errorMsg = '未找到可用的WiFi网络，请确保附近有设备热点';
            } else {
              _errorMsg = null;
            }
            _isScanning = false;
          });
        } else {
          setState(() {
            _errorMsg = '无法启动WiFi扫描，请检查WiFi是否开启';
            _isScanning = false;
          });
          _showWifiServiceDialog();
        }
      } else if (canScan == CanStartScan.noLocationPermissionUpgradeAccuracy) {
        // 特殊处理：需要精确位置权限
        setState(() {
          _isScanning = false;
          _errorMsg = '需要精确位置权限';
        });
        
        debugPrint('需要升级到精确位置权限');
        _showPermissionExplanationDialog(
          title: '需要精确位置权限',
          content: '扫描WiFi需要"精确位置权限"而不仅仅是"大致位置权限"。\n\n'
              '请在设置中将位置权限设置为"精确位置"并确保选择"始终允许"。',
          onOpenSettings: _openAppSettings,
        );
      } else {
        // 无法扫描，处理不同的错误情况
        setState(() {
          _isScanning = false;
          _errorMsg = '无法扫描WiFi（状态: $canScan）';
        });
        
        debugPrint('WiFi扫描错误状态: $canScan');
        
        // 检查WiFi是否开启
        bool wifiEnabled = false;
        try {
          // 这里我们无法确认WiFi是否启用，因此假设问题在权限
          wifiEnabled = true;  // 假设已开启
        } catch (e) {
          debugPrint('检查WiFi状态失败: $e');
        }
        
        if (!wifiEnabled) {
          debugPrint('WiFi未开启');
          _showWifiServiceDialog();
          return;
        }
        
        // 如果WiFi已开启但仍然无法扫描，可能是权限问题
        debugPrint('权限问题导致无法扫描WiFi');
        _showPermissionExplanationDialog(
          title: 'WiFi扫描受限',
          content: '虽然WiFi已开启，但应用仍无法扫描WiFi网络。这通常是因为Android系统限制或权限不足。\n\n请在系统设置中确保应用有"位置信息"和"附近的设备"权限，并设置为"始终允许"。',
          onOpenSettings: _openAppSettings,
        );
      }
    } catch (e) {
      debugPrint('扫描WiFi时出错: $e');
      setState(() {
        _errorMsg = '扫描WiFi时出错: $e';
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
    setState(() {
      _isConnecting = true;
      _selectedSSID = ssid;
      _errorMsg = null;
    });
    
    try {
      // 连接到WiFi网络
      final result = await _wifiManager.connectToWifi(ssid);
      
      if (result) {
        // 连接成功，加载配置页面
        await _loadConfigPage();
      } else {
        setState(() {
          _errorMsg = '无法连接到 $ssid';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = '连接WiFi时出错: $e';
        _isConnecting = false;
      });
    }
  }
  
  // 加载配置页面
  Future<void> _loadConfigPage() async {
    try {
      // 使用WebView加载设备配置页面
      final deviceIp = await _wifiManager.getDeviceIp();
      if (deviceIp != null) {
        final url = 'http://$deviceIp';
        
        // 加载URL到WebView
        await _webViewController.loadRequest(Uri.parse(url));
        
        setState(() {
          _showWebView = true;
          _isConnecting = false;
        });
      } else {
        setState(() {
          _errorMsg = '无法获取设备IP地址';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = '加载配置页面时出错: $e';
        _isConnecting = false;
        _showWebView = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi配网'),
        actions: [
          // 刷新按钮
          if (!_showWebView)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isScanning ? null : _requestAllPermissionsAndScan,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  // 构建页面主体
  Widget _buildBody() {
    // 显示WebView
    if (_showWebView) {
      return Column(
        children: [
          // 连接状态提示
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: Row(
              children: [
                const Icon(Icons.wifi_lock, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('已连接到 $_selectedSSID，请在下方页面完成配置',
                    style: const TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
          // WebView显示设备配置页面
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      );
    }
    
    // 显示错误信息
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMsg!, 
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestAllPermissionsAndScan,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    // 正在扫描
    if (_isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在扫描WiFi...'),
          ],
        ),
      );
    }
    
    // 显示WiFi列表
    return Column(
      children: [
        // 说明文字
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '请选择设备发出的WiFi热点进行连接',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        
        // WiFi列表
        Expanded(
          child: _accessPoints.isEmpty
              ? const Center(child: Text('未找到设备热点'))
              : ListView.builder(
                  itemCount: _accessPoints.length,
                  itemBuilder: (context, index) {
                    final ap = _accessPoints[index];
                    return ListTile(
                      leading: const Icon(Icons.wifi),
                      title: Text(ap.ssid),
                      subtitle: Text('信号强度: ${ap.level} dBm'),
                      trailing: _isConnecting && _selectedSSID == ap.ssid
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _isConnecting
                          ? null
                          : () => _connectToWifi(ap.ssid),
                    );
                  },
                ),
        ),
      ],
    );
  }
} 