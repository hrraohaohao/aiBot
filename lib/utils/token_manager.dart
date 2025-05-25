import 'package:flutter/foundation.dart';

/// Token管理工具类，负责保存、获取和清除登录令牌
class TokenManager {
  // 键名常量
  static const String _tokenKey = 'auth_token';
  static const String _expireTimeKey = 'auth_expire_time';
  static const String _clientHashKey = 'client_hash';
  
  // 暂时使用内存存储替代shared_preferences，以解决iOS编译问题
  static String? _token;
  static int? _expireTime;
  static String? _clientHash;
  
  /// 保存登录令牌信息
  static Future<void> saveToken(String token, int expireTime, String clientHash) async {
    _token = token;
    _expireTime = expireTime;
    _clientHash = clientHash;
    debugPrint('保存token: $token, 过期时间: $expireTime, 客户端哈希: $clientHash');
  }
  
  /// 获取保存的令牌
  static Future<String?> getToken() async {
    return _token;
  }
  
  /// 获取令牌过期时间
  static Future<int?> getExpireTime() async {
    return _expireTime;
  }
  
  /// 获取客户端哈希值
  static Future<String?> getClientHash() async {
    return _clientHash;
  }
  
  /// 检查令牌是否有效（存在且未过期）
  static Future<bool> isTokenValid() async {
    // 如果没有token，直接返回false
    if (_token == null || _expireTime == null) {
      return false;
    }

    // 检查token是否过期（expireTime是秒级时间戳）
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000; // 转换为秒
    return _expireTime! > currentTime;
  }
  
  /// 清除所有登录令牌信息
  static Future<void> clearToken() async {
    _token = null;
    _expireTime = null;
    _clientHash = null;
    debugPrint('清除token信息');
  }
} 