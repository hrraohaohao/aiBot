import 'package:flutter/material.dart';
import '../pages/login/login_page.dart';

class AppRoutes {
  // 路由名称常量
  static const String home = '/';
  static const String login = '/login';
  
  // 路由表
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
  };
  
  // 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const LoginPage(),
    );
  }
} 