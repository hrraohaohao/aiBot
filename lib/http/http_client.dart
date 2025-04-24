import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/header_interceptor.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  late Dio dio;
  
  // 单例模式
  factory HttpClient() => _instance;
  
  // 私有构造函数
  HttpClient._internal() {
    dio = Dio();
    _initDio();
  }
  
  // 初始化Dio配置
  void _initDio() {
    // 基础配置
    dio.options = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl, // 使用环境配置中的API地址
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );
    
    // 添加拦截器
    dio.interceptors.add(HeaderInterceptor());
    dio.interceptors.add(LoggingInterceptor());
    dio.interceptors.add(ErrorInterceptor());
  }
  
  // 设置基础URL
  void setBaseUrl(String url) {
    dio.options.baseUrl = url;
  }
  
  // 设置请求头
  void setHeaders(Map<String, dynamic> headers) {
    dio.options.headers.addAll(headers);
  }
  
  // 设置认证token
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  // GET请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } catch (e) {
      rethrow;
    }
  }
  
  // POST请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } catch (e) {
      rethrow;
    }
  }
  
  // PUT请求
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } catch (e) {
      rethrow;
    }
  }
  
  // DELETE请求
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } catch (e) {
      rethrow;
    }
  }
} 