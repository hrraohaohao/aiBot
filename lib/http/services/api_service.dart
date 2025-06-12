import '../http_client.dart';
import '../models/api_response.dart';
import '../exceptions/api_exception.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:dio/io.dart';
import '../../utils/token_manager.dart';
import 'package:flutter/material.dart';
import '../../utils/event_bus.dart';

class ApiService {
  final HttpClient _httpClient = HttpClient();
  late Dio _dio;
  String _baseUrl = '';

  // 初始化服务
  ApiService() {
    // 可以在这里设置特定的服务配置
    _initDio();
  }

  // 设置基础URL
  void setBaseUrl(String url) {
    _httpClient.setBaseUrl(url);
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  // 设置身份验证token
  void setToken(String token) {
    _httpClient.setToken(token);
    // 确保添加Bearer前缀
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 初始化 Dio 并配置
  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'content-type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': '1.0.0',
        'X-Platform': 'flutter',
      },
    ));
    
    // 禁用证书验证 (仅在开发环境使用)
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true; // 返回true将接受任何证书
      };
      return client;
    };
    
    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    
    // 添加请求拦截器，自动添加token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 从TokenManager获取token
        final token = await TokenManager.getToken();
        if (token != null && token.isNotEmpty) {
          // 添加Bearer前缀
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // 检查业务状态码是否为401
        if (response.data is Map && response.data['code'] == 401) {
          debugPrint('业务状态码401，需要重新登录: ${response.data['msg']}');
          
          // 清除token
          await TokenManager.clearToken();
          
          // 发送未授权事件
          EventBus.instance.fire(UnauthorizedEvent(
            response.data['msg'] ?? 'token is invalid, please log in again'
          ));
        }
        return handler.next(response);
      },
    ));
  }
  
  // GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // 处理响应数据是Map类型的情况
        if (responseData is Map) {
          // 检查业务状态码
          final code = responseData['code'];
          
          if (code != null && code != 200 && code != 0) {
            // 业务逻辑错误
            return ApiResponse<T>(
              success: false,
              code: code,
              message: responseData['msg'] ?? responseData['message'] ?? '未知错误',
            );
          }
          
          // 业务逻辑成功
          if (fromJson != null && responseData['data'] != null) {
            return ApiResponse<T>(
              success: true,
              code: code ?? 200,
              message: responseData['msg'] ?? responseData['message'] ?? 'Success',
              data: fromJson(responseData['data']),
            );
          }
          
          // 没有data字段或不需要解析
          return ApiResponse<T>(
            success: true,
            code: code ?? 200,
            message: responseData['msg'] ?? responseData['message'] ?? 'Success',
            data: null,
          );
        }
        
        // 直接返回非Map类型的数据
        if (fromJson != null && responseData != null) {
          return ApiResponse<T>(
            success: true,
            message: 'Success',
            data: fromJson(responseData),
          );
        }
        
        return ApiResponse<T>(
          success: true,
          message: 'Success',
          data: responseData as T,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          code: response.statusCode ?? 500,
          message: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        code: e is DioException ? e.response?.statusCode ?? 500 : 500,
        message: e is DioException ? e.message ?? 'Unknown error' : e.toString(),
      );
    }
  }

  // POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // 处理响应数据是Map类型的情况
        if (responseData is Map) {
          // 检查业务状态码
          final code = responseData['code'];
          
          if (code != null && code != 200 && code != 0) {
            // 业务逻辑错误
            return ApiResponse<T>(
              success: false,
              code: code,
              message: responseData['msg'] ?? responseData['message'] ?? '未知错误',
            );
          }
          
          // 业务逻辑成功
          if (fromJson != null && responseData['data'] != null) {
            return ApiResponse<T>(
              success: true,
              code: code ?? 200,
              message: responseData['msg'] ?? responseData['message'] ?? 'Success',
              data: fromJson(responseData['data']),
            );
          }
          
          // 没有data字段或不需要解析
          return ApiResponse<T>(
            success: true,
            code: code ?? 200,
            message: responseData['msg'] ?? responseData['message'] ?? 'Success',
            data: null,
          );
        }
        
        // 直接返回非Map类型的数据
        if (fromJson != null && responseData != null) {
          return ApiResponse<T>(
            success: true,
            message: 'Success',
            data: fromJson(responseData),
          );
        }
        
        return ApiResponse<T>(
          success: true,
          message: 'Success',
          data: responseData as T,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          code: response.statusCode ?? 500,
          message: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        code: e is DioException ? e.response?.statusCode ?? 500 : 500,
        message: e is DioException ? e.message ?? 'Unknown error' : e.toString(),
      );
    }
  }
  
  // 获取dio实例，用于测试或特殊处理
  Dio get dio => _dio;
  
  // 手动添加授权头，确保每个请求都有
  void addAuthorizationHeader() async {
    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
} 