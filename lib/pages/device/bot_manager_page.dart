import 'package:flutter/material.dart';
import 'dart:ui';
import '../../http/services/agent_service.dart';
import '../../http/models/device_model.dart';
import 'bot_connect_page.dart';

// 设备状态枚举
enum DeviceStatus {
  online,    // 在线
  offline,   // 离线
  charging,  // 充电中
  noNetwork, // 无网络连接
}

// 设备状态扩展
extension DeviceStatusExtension on DeviceStatus {
  String get text {
    switch (this) {
      case DeviceStatus.online:
        return '在线';
      case DeviceStatus.offline:
        return '离线';
      case DeviceStatus.charging:
        return '充电中';
      case DeviceStatus.noNetwork:
        return '无网络连接';
    }
  }
  
  Color get color {
    switch (this) {
      case DeviceStatus.online:
        return Colors.green;
      case DeviceStatus.offline:
        return Colors.grey;
      case DeviceStatus.charging:
        return Colors.orange;
      case DeviceStatus.noNetwork:
        return Colors.blue;
    }
  }
}

class BotManagerPage extends StatefulWidget {
  final String agentId;
  final String agentName;
  
  const BotManagerPage({
    Key? key, 
    required this.agentId,
    required this.agentName,
  }) : super(key: key);

  @override
  State<BotManagerPage> createState() => _BotManagerPageState();
}

class _BotManagerPageState extends State<BotManagerPage> {
  // 用户服务
  final AgentService _agentService = AgentService();
  
  // 设备列表
  List<DeviceModel> _deviceList = [];
  
  // 是否正在加载
  bool _isLoading = true;
  
  // 是否处于管理模式
  bool _isManageMode = false;
  
  // 选中的设备ID (单选)
  String? _selectedDeviceId;
  
  @override
  void initState() {
    super.initState();
    _agentService.init();
    // 加载设备列表
    _loadDeviceList();
  }
  
  // 加载绑定的设备列表
  Future<void> _loadDeviceList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _agentService.getBindBotList(agentId: widget.agentId);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        setState(() {
          _deviceList = response.data!;
        });
      } else {
        setState(() {
          _deviceList = [];
        });
      }
    } catch (e) {
      debugPrint('加载设备列表失败: $e');
      setState(() {
        _deviceList = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 切换管理模式
  void _toggleManageMode() {
    setState(() {
      _isManageMode = !_isManageMode;
      if (!_isManageMode) {
        _selectedDeviceId = null;
      }
    });
  }
  
  // 选择设备
  void _selectDevice(String deviceId) {
    setState(() {
      if (_selectedDeviceId == deviceId) {
        _selectedDeviceId = null; // 如果点击已选中的设备，则取消选择
      } else {
        _selectedDeviceId = deviceId; // 选择新设备
      }
    });
  }
  
  // 解绑选中的设备
  Future<void> _unbindSelectedDevice() async {
    if (_selectedDeviceId == null) {
      return;
    }
    
    // 获取选中的设备
    final selectedDevice = _deviceList.firstWhere(
      (device) => device.id == _selectedDeviceId,
      orElse: () => _deviceList.first,
    );
    
    // 显示确认对话框
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认解绑'),
        content: Text('确定要解绑设备吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // 显示加载状态
        setState(() {
          _isLoading = true;
        });
        
        // 调用解绑设备接口
        final response = await _agentService.unbindBot(
          deviceId: selectedDevice.id,
        );
        
        if (response.success) {
          // 先退出管理模式
          setState(() {
            _selectedDeviceId = null;
            _isManageMode = false;
          });
          
          // 显示成功消息
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('设备解绑成功')),
          );
          
          // 重新加载设备列表
          await _loadDeviceList();
        } else {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('解绑失败: ${response.message}')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解绑失败: $e')),
        );
      }
    }
  }
  
  // 获取随机设备状态（模拟用）
  DeviceStatus _getDeviceStatus(int index) {
    // 使用固定的状态来对应不同的状态
    switch (index % 4) {
      case 0:
        return DeviceStatus.charging;
      case 1:
        return DeviceStatus.offline;
      case 2:
        return DeviceStatus.online;
      case 3:
        return DeviceStatus.noNetwork;
      default:
        return DeviceStatus.offline;
    }
  }

  // 显示绑定设备弹窗
  Future<void> _showBindDeviceDialog() async {
    final TextEditingController codeController = TextEditingController();
    bool isProcessing = false;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
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
                    const Center(
                      child: Text(
                        '绑定设备',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 提示文字
                    const Text(
                      '请输入设备播报的6位验证码',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // 输入框
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 8.0,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        hintText: '6位数验证码',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          letterSpacing: 4.0,
                        ),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 按钮区
                    Row(
                      children: [
                        // 取消按钮
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessing 
                                ? null 
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F5),
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '取消',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // 确认按钮
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessing 
                                ? null 
                                : () async {
                                    final code = codeController.text.trim();
                                    if (code.length != 6 || int.tryParse(code) == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('请输入有效的6位数字验证码')),
                                      );
                                      return;
                                    }
                                    
                                    // 设置处理中状态
                                    setState(() {
                                      isProcessing = true;
                                    });
                                    
                                    // 调用绑定设备接口
                                    try {
                                      final response = await _agentService.bindBot(
                                        agentId: widget.agentId,
                                        deviceCode: code,
                                      );
                                      
                                      Navigator.of(context).pop();
                                      
                                      if (response.success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('设备绑定成功')),
                                        );
                                        
                                        // 立即刷新设备列表
                                        setState(() {
                                          _isLoading = true; // 显示加载状态
                                        });
                                        
                                        // 直接刷新列表，不使用延迟
                                        _loadDeviceList();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('绑定失败: ${response.message}')),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('绑定失败: $e')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3C8BFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    '确认',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.agentName,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // 管理按钮
          TextButton(
            onPressed: _toggleManageMode,
            child: Text(
              _isManageMode ? '完成' : '管理',
              style: const TextStyle(
                color: Color(0xFF3C8BFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 设备列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _deviceList.isEmpty
                    ? _buildEmptyState()
                    : _buildDeviceList(),
          ),
          
          // 底部按钮区域
          if (!_isLoading && _deviceList.isNotEmpty)
            _buildBottomActions(),
        ],
      ),
    );
  }
  
  // 构建底部操作区域
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 82, // 固定高度，防止切换时布局抖动
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isManageMode && _selectedDeviceId != null
            ? SizedBox(
                key: const ValueKey('unbind'),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _unbindSelectedDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Colors.red),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '解绑设备',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              )
            : SizedBox(
                key: const ValueKey('bind'),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showBindDeviceDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C8BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '绑定设备',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
  
  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/icon_bot_empty.png',
            width: 119,
            height: 93,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无设备',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          // 添加绑定设备按钮
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _showBindDeviceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C8BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                '绑定设备',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建设备列表
  Widget _buildDeviceList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 每行两个
        childAspectRatio: 1.0, // 宽高比
        crossAxisSpacing: 16, // 水平间距
        mainAxisSpacing: 16, // 垂直间距
      ),
      itemCount: _deviceList.length,
      itemBuilder: (context, index) {
        final device = _deviceList[index];
        final status = _getDeviceStatus(index);
        final isSelected = device.id == _selectedDeviceId;
        
        return GestureDetector(
          onTap: () {
            if (_isManageMode) {
              _selectDevice(device.id);
            } else {
              // TODO: 实现设备详情页面跳转
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('查看设备: ${device.alias}')),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isManageMode && isSelected ? const Color(0xFF3C8BFF) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 设备内容
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 设备名称和状态
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '面包板新版接线',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 机器人图片（靠右）
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Image.asset(
                            'assets/images/icon_bot_online.png',
                            width: 75,
                            height: 58,
                          ),
                        ),
                      ),
                    ),
                    
                    // 如果是在线状态，显示提醒消息
                    if (status == DeviceStatus.online)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEEDED),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '2条新的警告',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF25B5B),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // 选中标记
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedOpacity(
                    opacity: _isManageMode && isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3C8BFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 