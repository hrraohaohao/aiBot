import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    print('┌───────────────────────────────────────────');
    print('│ 请求方法: ${options.method}');
    print('│ 请求地址: $requestPath');
    print('│ 请求头: ${options.headers}');
    if (options.queryParameters.isNotEmpty) {
      print('│ 查询参数: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('│ 请求体: ${options.data}');
    }
    print('└───────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌───────────────────────────────────────────');
    print('│ 响应码: ${response.statusCode}');
    print('│ 响应数据: ${response.data}');
    print('└───────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌───────────────────────────────────────────');
    print('│ 错误类型: ${err.type}');
    print('│ 错误信息: ${err.message}');
    if (err.response != null) {
      print('│ 错误状态码: ${err.response?.statusCode}');
      print('│ 错误数据: ${err.response?.data}');
    }
    print('└───────────────────────────────────────────');
    super.onError(err, handler);
  }
} 