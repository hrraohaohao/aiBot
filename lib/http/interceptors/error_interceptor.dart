import 'package:dio/dio.dart';
import '../exceptions/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException(message: '网络连接超时', code: err.response?.statusCode);
        
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw ApiException(message: '请求参数错误', code: 400);
          case 401:
            throw ApiException(message: '未授权，请登录', code: 401);
          case 403:
            throw ApiException(message: '拒绝访问', code: 403);
          case 404:
            throw ApiException(message: '请求地址错误', code: 404);
          case 500:
            throw ApiException(message: '服务器内部错误', code: 500);
          case 502:
            throw ApiException(message: '网关错误', code: 502);
          case 503:
            throw ApiException(message: '服务不可用', code: 503);
          case 505:
            throw ApiException(message: 'HTTP版本不支持', code: 505);
          default:
            throw ApiException(
              message: '网络错误 ${err.response?.statusCode}',
              code: err.response?.statusCode,
            );
        }
        
      case DioExceptionType.cancel:
        throw ApiException(message: '请求取消', code: err.response?.statusCode);
        
      case DioExceptionType.unknown:
        throw ApiException(message: '网络错误，请检查网络连接', code: err.response?.statusCode);
        
      default:
        throw ApiException(message: '未知错误', code: err.response?.statusCode);
    }
  }
} 