import 'package:ai_bot/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/token_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小Xin机器人',
      theme: ThemeData(
        primaryColor: const Color(0xFF3C8BFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3C8BFF),
          primary: const Color(0xFF3C8BFF),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

// 启动页面，用于检查登录状态并跳转
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 检查登录状态，决定跳转页面
  Future<void> _checkLoginStatus() async {
    // 检查是否已登录
    final isLoggedIn = await TokenManager.isTokenValid();
    debugPrint('isLoggedIn $isLoggedIn');
    if (mounted) {
      // 根据登录状态跳转
      if (isLoggedIn) {
        debugPrint('登录信息有效，跳转到首页');
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        debugPrint('登录信息无效，跳转到登录页');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用logo
            FlutterLogo(size: 80),
            SizedBox(height: 24),
            // 加载指示器
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
