import 'package:flutter/material.dart';
import '../pages/login/login_page.dart';
import '../pages/login/register_page.dart';
import '../pages/login/verification_page.dart';
import '../pages/login/set_password_page.dart';

class AppRoutes {
  // 路由名称常量
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String setPassword = '/set_password';
  
  // 路由表
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
  };
  
  // 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // 解析路由参数
    final args = settings.arguments as Map<String, dynamic>?;
    
    switch (settings.name) {
      case verification:
        // 验证码页面需要传入手机号
        final phone = args?['phone'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VerificationPage(phoneNumber: phone),
        );
        
      case setPassword:
        // 设置密码页面需要传入手机号
        final phone = args?['phone'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SetPasswordPage(phoneNumber: phone),
        );
        
      default:
        // 默认返回登录页面
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginPage(),
        );
    }
  }
} 