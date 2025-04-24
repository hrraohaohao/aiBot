import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加通用请求头
    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // 可以在这里添加其他通用请求头
      'X-App-Version': '1.0.0',
      'X-Platform': 'flutter',
    });
    
    // 如果需要，可以在这里添加设备信息、语言等
    
    return super.onRequest(options, handler);
  }
} 