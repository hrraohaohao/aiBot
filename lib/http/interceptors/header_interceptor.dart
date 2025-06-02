import 'package:dio/dio.dart';
import '../../utils/token_manager.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 添加通用请求头
    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // 可以在这里添加其他通用请求头
      'X-App-Version': '1.0.0',
      'X-Platform': 'flutter',
    });
    
    // 从TokenManager获取token
    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return super.onRequest(options, handler);
  }
} 