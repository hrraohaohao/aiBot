import 'package:flutter/foundation.dart';
import '../http/models/login_response.dart';

/// 用户管理类，负责管理用户信息
class UserManager {
  // 单例模式
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();
  
  // 用户信息
  UserInfo? _userInfo;
  
  // 用户信息变更通知
  final ValueNotifier<UserInfo?> userInfoNotifier = ValueNotifier<UserInfo?>(null);
  
  // 获取用户信息
  UserInfo? get userInfo => _userInfo;
  
  // 设置用户信息
  void setUserInfo(UserInfo? userInfo) {
    _userInfo = userInfo;
    userInfoNotifier.value = userInfo;
    debugPrint('用户信息已更新: ${userInfo?.username}');
  }
  
  // 清除用户信息
  void clearUserInfo() {
    _userInfo = null;
    userInfoNotifier.value = null;
    debugPrint('用户信息已清除');
  }
  
  // 检查用户是否已登录
  bool get isLoggedIn => _userInfo != null;
} 