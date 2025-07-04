import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

/// WiFi配置管理器，负责管理WiFi连接和配置
class WiFiConfigManager {
  // 设备IP地址，通常是网关
  static const String _defaultDeviceIp = '192.168.4.1';
  
  // 连接超时时间(秒)
  static const int _connectionTimeout = 15;
  
  // 原生平台通道
  static const platform = MethodChannel('com.example.ai_bot/wifi_provision');
  
  /// 连接到WiFi网络
  Future<bool> connectToWifi(String ssid, String? password) async {
    try {
      debugPrint('尝试连接到WiFi: $ssid');
      
      // 检查WiFi权限
      if (!await checkWiFiPermission()) {
        debugPrint('WiFi权限未授予');
        return false;
      }
      
      // 检查WiFi是否开启
      if (!(await WiFiForIoTPlugin.isEnabled())) {
        debugPrint('WiFi未开启');
        return false;
      }
      
      // 确定安全类型
      final NetworkSecurity security = (password == null || password.isEmpty) 
          ? NetworkSecurity.NONE 
          : NetworkSecurity.WPA;
      
      // 连接到WiFi
      try {
        // 使用Flutter插件连接WiFi
        final result = await WiFiForIoTPlugin.connect(
          ssid,
          password: password ?? '',
          joinOnce: true,
          security: security,
          timeoutInSeconds: _connectionTimeout,
        );
        
        debugPrint('WiFi连接结果: $result');
        
        // 等待连接稳定
        await Future.delayed(const Duration(seconds: 2));
        
        return result;
      } catch (e) {
        debugPrint('使用WiFiForIoTPlugin连接失败: $e');
        
        // 尝试使用原生方法连接
        try {
          final result = await platform.invokeMethod('connectToWiFi', {
            'ssid': ssid,
            'password': password ?? '',
          });
          debugPrint('使用原生方法连接结果: $result');
          
          // 等待连接稳定
          await Future.delayed(const Duration(seconds: 2));
          
          return result == true;
        } catch (e) {
          debugPrint('使用原生方法连接失败: $e');
          return false;
        }
      }
    } catch (e) {
      debugPrint('连接WiFi出错: $e');
      return false;
    }
  }
  
  /// 检查WiFi权限
  Future<bool> checkWiFiPermission() async {
    if (Platform.isAndroid) {
      final locationPermission = await Permission.locationWhenInUse.status;
      if (!locationPermission.isGranted) {
        return false;
      }
      
      // Android 12+需要附近设备权限
      if (await Permission.nearbyWifiDevices.shouldShowRequestRationale) {
        final nearbyDevicesPermission = await Permission.nearbyWifiDevices.status;
        if (!nearbyDevicesPermission.isGranted) {
          return false;
        }
      }
    }
    return true;
  }
  
  /// 请求WiFi相关权限
  Future<bool> requestWiFiPermission() async {
    if (Platform.isAndroid) {
      final locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        return false;
      }
      
      // Android 12+需要附近设备权限
      if (await Permission.nearbyWifiDevices.shouldShowRequestRationale) {
        final nearbyDevicesStatus = await Permission.nearbyWifiDevices.request();
        if (!nearbyDevicesStatus.isGranted) {
          return false;
        }
      }
    }
    return true;
  }
  
  /// 获取设备IP地址
  Future<String> getDeviceIp() async {
    // 直接返回固定IP
    return '192.168.4.1';
  }
  
  /// 获取当前连接的WiFi SSID
  Future<String?> getCurrentWifiSSID() async {
    try {
      // 尝试使用Flutter插件获取当前SSID
      try {
        final ssid = await WiFiForIoTPlugin.getSSID();
        if (ssid != null && ssid.isNotEmpty && ssid != "<unknown ssid>") {
          return ssid;
        }
      } catch (e) {
        debugPrint('使用WiFiForIoTPlugin获取SSID失败: $e');
      }
      
      // 尝试使用原生方法获取SSID
      try {
        final ssid = await platform.invokeMethod('getCurrentWifiSSID');
        if (ssid != null && ssid.toString().isNotEmpty) {
          return ssid.toString();
        }
      } catch (e) {
        debugPrint('使用原生方法获取SSID失败: $e');
      }
      
      return null;
    } catch (e) {
      debugPrint('获取当前WiFi SSID出错: $e');
      return null;
    }
  }
} 