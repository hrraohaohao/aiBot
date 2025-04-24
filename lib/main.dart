import 'package:flutter/material.dart';
import 'config/env_config.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小Xin机器人',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 设置应用路由
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // 环境标识
      builder: (context, child) {
        // 只在非生产环境显示环境标识
        if (!EnvConfig.isProduction) {
          return Banner(
            location: BannerLocation.topEnd,
            message: EnvConfig.environmentName,
            color: _getEnvironmentColor(),
            child: child!,
          );
        }
        return child!;
      },
    );
  }
  
  // 根据环境返回不同颜色
  Color _getEnvironmentColor() {
    if (EnvConfig.isProduction) {
      return Colors.green;
    } else if (EnvConfig.isStaging) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
