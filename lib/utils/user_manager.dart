import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/models/user_model.dart';

/// 用户管理类，负责管理用户信息
class UserManager {
  // 单例模式
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();
  
  // 用户信息通知器
  final ValueNotifier<UserModel?> userInfoNotifier = ValueNotifier<UserModel?>(null);
  
  // 存储键
  static const String _userInfoKey = 'user_info';
  
  // 初始化 - 从本地加载用户信息
  Future<void> init() async {
    await loadUserInfo();
  }
  
  // 保存用户信息到本地
  Future<void> saveUserInfo(UserModel userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoJson = jsonEncode(userInfo.toJson());
      await prefs.setString(_userInfoKey, userInfoJson);
      
      debugPrint('用户信息已保存到本地: username=${userInfo.username}');
      
      // 更新通知器
      userInfoNotifier.value = userInfo;
    } catch (e) {
      debugPrint('保存用户信息失败: $e');
    }
  }
  
  // 从本地加载用户信息
  Future<void> loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoJson = prefs.getString(_userInfoKey);
      
      debugPrint('从本地加载用户信息: ${userInfoJson ?? "无数据"}');
      
      if (userInfoJson != null) {
        final userInfoMap = jsonDecode(userInfoJson) as Map<String, dynamic>;
        final userInfo = UserModel.fromJson(userInfoMap);
        
        // 更新通知器
        userInfoNotifier.value = userInfo;
        debugPrint('用户信息加载成功: username=${userInfo.username}');
      } else {
        debugPrint('本地没有保存的用户信息');
      }
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
    }
  }
  
  // 清除用户信息
  Future<void> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userInfoKey);
      
      // 更新通知器
      userInfoNotifier.value = null;
    } catch (e) {
      debugPrint('清除用户信息失败: $e');
    }
  }
  
  // 获取用户信息
  UserModel? get userInfo => userInfoNotifier.value;
} 