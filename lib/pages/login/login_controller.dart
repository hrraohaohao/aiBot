import 'package:flutter/material.dart';

class LoginController {
  // 单例模式
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  LoginController._internal();
  
  // 登录方法
  Future<bool> login(String phone, String password) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 这里是简单的演示逻辑，实际中应该调用API服务
    if (phone == '13800138000' && password == '123456') {
      // 登录成功的处理
      _saveToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      return true;
    } else {
      // 登录失败
      return false;
    }
  }
  
  // 保存token
  void _saveToken(String token) {
    // TODO: 实际项目中应该保存到安全存储
    print('保存token: $token');
  }
  
  // 显示协议
  void showTerms(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 