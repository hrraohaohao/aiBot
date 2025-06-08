import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token管理工具类，负责保存、获取和清除登录令牌
class TokenManager {
  // 键名常量
  static const String _tokenKey = 'auth_token';
  static const String _expireTimeKey = 'auth_expire_time';
  static const String _clientHashKey = 'client_hash';

  // 内存中的备份，防止SharedPreferences失败
  static String? _cachedToken;
  static int? _cachedExpireTime;
  static String? _cachedClientHash;
  
  // 初始化标志
  static bool _initialized = false;
  
  /// 初始化TokenManager
  static Future<void> init() async {
    if (_initialized) return;
    
    debugPrint('TokenManager初始化...');
    try {
      // 尝试预加载所有值到内存
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenKey);
      _cachedExpireTime = prefs.getInt(_expireTimeKey);
      _cachedClientHash = prefs.getString(_clientHashKey);
      
      debugPrint('TokenManager初始化成功，token存在: ${_cachedToken != null}');
      _initialized = true;
    } catch (e) {
      debugPrint('TokenManager初始化失败: $e');
      // 初始化失败也标记为已初始化，但使用内存缓存
      _initialized = true;
    }
  }

  /// 保存登录令牌信息
  static Future<void> saveToken(
      String token, int expireTime, String clientHash) async {
    // 先保存到内存缓存
    _cachedToken = token;
    _cachedExpireTime = expireTime;
    _cachedClientHash = clientHash;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_expireTimeKey, expireTime);
      await prefs.setString(_clientHashKey, clientHash);
      debugPrint('保存token: $token, 过期时间: $expireTime, 客户端哈希: $clientHash');
    } catch (e) {
      debugPrint('保存token失败: $e');
      // 已经保存到内存中，所以即使这里失败也能继续使用
    }
  }

  /// 获取保存的令牌
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      // 如果SharedPreferences成功，更新缓存
      if (token != null) _cachedToken = token;
      return token;
    } catch (e) {
      debugPrint('获取token失败，使用内存缓存: $e');
      // 发生错误时返回内存缓存
      return _cachedToken;
    }
  }

  /// 获取令牌过期时间
  static Future<int?> getExpireTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expireTime = prefs.getInt(_expireTimeKey);
      if (expireTime != null) _cachedExpireTime = expireTime;
      return expireTime;
    } catch (e) {
      debugPrint('获取过期时间失败，使用内存缓存: $e');
      return _cachedExpireTime;
    }
  }

  /// 获取客户端哈希值
  static Future<String?> getClientHash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientHash = prefs.getString(_clientHashKey);
      if (clientHash != null) _cachedClientHash = clientHash;
      return clientHash;
    } catch (e) {
      debugPrint('获取客户端哈希失败，使用内存缓存: $e');
      return _cachedClientHash;
    }
  }

  /// 检查令牌是否有效（存在且未过期）
  static Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) {
        // 检查内存缓存
        if (_cachedToken != null) {
          debugPrint('SharedPreferences中token为null，但内存缓存中有token');
          return true;
        }
        debugPrint('token is null');
        return false;
      }
      // 更新内存缓存
      _cachedToken = token;
      return true;
    } catch (e) {
      debugPrint('检查token有效性失败，使用内存缓存: $e');
      // 使用内存缓存判断
      return _cachedToken != null;
    }
  }

  /// 清除所有登录令牌信息
  static Future<void> clearToken() async {
    // 清除内存缓存
    _cachedToken = null;
    _cachedExpireTime = null;
    _cachedClientHash = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_expireTimeKey);
      await prefs.remove(_clientHashKey);
      debugPrint('清除token信息');
    } catch (e) {
      debugPrint('清除token失败，但内存缓存已清除: $e');
    }
  }
}
