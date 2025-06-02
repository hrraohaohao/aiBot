import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token管理工具类，负责保存、获取和清除登录令牌
class TokenManager {
  // 键名常量
  static const String _tokenKey = 'auth_token';
  static const String _expireTimeKey = 'auth_expire_time';
  static const String _clientHashKey = 'client_hash';

  /// 保存登录令牌信息
  static Future<void> saveToken(
      String token, int expireTime, String clientHash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_expireTimeKey, expireTime);
    await prefs.setString(_clientHashKey, clientHash);
    debugPrint('保存token: $token, 过期时间: $expireTime, 客户端哈希: $clientHash');
  }

  /// 获取保存的令牌
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 获取令牌过期时间
  static Future<int?> getExpireTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expireTimeKey);
  }

  /// 获取客户端哈希值
  static Future<String?> getClientHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clientHashKey);
  }

  /// 检查令牌是否有效（存在且未过期）
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      debugPrint('token is null ');
      return false;
    }
    return true;
  }

  /// 清除所有登录令牌信息
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expireTimeKey);
    await prefs.remove(_clientHashKey);
    debugPrint('清除token信息');
  }
}
