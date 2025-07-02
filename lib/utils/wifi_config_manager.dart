import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/// WiFi配置管理器，负责管理WiFi连接和配置
class WiFiConfigManager {
  // 设备IP地址，通常是网关
  static const String _defaultDeviceIp = '192.168.4.1';
  
  // 连接超时时间(秒)
  static const int _connectionTimeout = 15;
  
  // 连接到指定SSID的WiFi
  Future<bool> connectToWifi(String ssid) async {
    try {
      debugPrint('尝试连接到WiFi: $ssid');
      
      // 检查权限
      final locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        debugPrint('缺少位置权限，无法连接WiFi');
        return false;
      }
      
      // 开启WiFi（如果未开启）
      if (!(await WiFiForIoTPlugin.isEnabled())) {
        await WiFiForIoTPlugin.setEnabled(true);
        // 等待WiFi启动
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // 使用Android平台相关方法连接WiFi
      // 注：实际情况可能需要更复杂的逻辑和错误处理
      try {
        // 尝试直接连接（无密码，通常设备热点是开放的）
        final result = await WiFiForIoTPlugin.connect(
          ssid,
          password: '',
          joinOnce: true,
          security: NetworkSecurity.NONE,
        );
        
        if (result) {
          // 等待连接完成
          final connected = await _waitForConnection(ssid);
          return connected;
        }
      } catch (e) {
        debugPrint('使用WiFiIoT插件连接失败: $e');
      }
      
      // 如果上面方法失败，尝试通过平台通道方式连接
      // 注意：这部分代码需要配合原生代码使用，这里只是示例
      return await _connectViaMethodChannel(ssid);
    } catch (e) {
      debugPrint('连接WiFi时出错: $e');
      return false;
    }
  }
  
  // 通过方法通道连接WiFi
  Future<bool> _connectViaMethodChannel(String ssid) async {
    const methodChannel = MethodChannel('com.example.ai_bot/wifi');
    try {
      final result = await methodChannel.invokeMethod('connectToWifi', {
        'ssid': ssid,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('平台方法调用失败: ${e.message}');
      return false;
    }
  }
  
  // 等待连接完成
  Future<bool> _waitForConnection(String ssid) async {
    final completer = Completer<bool>();
    int attempts = 0;
    
    // 创建定时器检查连接状态
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      attempts++;
      
      try {
        final currentSsid = await WiFiForIoTPlugin.getSSID();
        debugPrint('当前SSID: $currentSsid, 目标SSID: $ssid');
        
        // 检查是否连接到了目标网络
        if (currentSsid == ssid) {
          timer.cancel();
          completer.complete(true);
          return;
        }
      } catch (e) {
        debugPrint('检查WiFi连接状态时出错: $e');
      }
      
      // 超时处理
      if (attempts >= _connectionTimeout) {
        timer.cancel();
        completer.complete(false);
      }
    });
    
    return completer.future;
  }
  
  // 获取设备IP地址
  Future<String?> getDeviceIp() async {
    try {
      // 等待网络连接稳定
      await Future.delayed(const Duration(seconds: 2));
      
      // 尝试获取网关地址，通常设备会作为网关
      String? gatewayIP;
      try {
        // 尝试获取当前连接的SSID，确认是否成功连接
        final currentSsid = await WiFiForIoTPlugin.getSSID();
        debugPrint('当前已连接到: $currentSsid');
        
        // 使用固定IP地址
        gatewayIP = _defaultDeviceIp;
      } catch (e) {
        debugPrint('获取SSID失败: $e');
      }
      
      if (gatewayIP != null && gatewayIP.isNotEmpty) {
        debugPrint('使用IP地址: $gatewayIP');
        return gatewayIP;
      }
      
      // 如果无法获取网关地址，返回默认设备IP
      debugPrint('使用默认设备IP: $_defaultDeviceIp');
      return _defaultDeviceIp;
    } catch (e) {
      debugPrint('获取设备IP时出错: $e');
      // 返回默认IP
      return _defaultDeviceIp;
    }
  }
} 