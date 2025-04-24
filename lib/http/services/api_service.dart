import '../http_client.dart';
import '../models/api_response.dart';
import '../exceptions/api_exception.dart';

class ApiService {
  final HttpClient _httpClient = HttpClient();

  // 初始化服务
  ApiService() {
    // 可以在这里设置特定的服务配置
  }

  // 设置基础URL
  void setBaseUrl(String url) {
    _httpClient.setBaseUrl(url);
  }

  // 设置身份验证token
  void setToken(String token) {
    _httpClient.setToken(token);
  }

  // GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null && response['data'] != null) {
        return ApiResponse<T>.fromJson(response, fromJson);
      }
      
      return ApiResponse<T>.fromJson(response, null);
    } on ApiException catch (e) {
      return ApiResponse<T>.error(e.message, code: e.code ?? 500);
    } catch (e) {
      return ApiResponse<T>.error('请求失败: $e');
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
      final response = await _httpClient.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null && response['data'] != null) {
        return ApiResponse<T>.fromJson(response, fromJson);
      }
      
      return ApiResponse<T>.fromJson(response, null);
    } on ApiException catch (e) {
      return ApiResponse<T>.error(e.message, code: e.code ?? 500);
    } catch (e) {
      return ApiResponse<T>.error('请求失败: $e');
    }
  }

  // PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null && response['data'] != null) {
        return ApiResponse<T>.fromJson(response, fromJson);
      }
      
      return ApiResponse<T>.fromJson(response, null);
    } on ApiException catch (e) {
      return ApiResponse<T>.error(e.message, code: e.code ?? 500);
    } catch (e) {
      return ApiResponse<T>.error('请求失败: $e');
    }
  }

  // DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _httpClient.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null && response['data'] != null) {
        return ApiResponse<T>.fromJson(response, fromJson);
      }
      
      return ApiResponse<T>.fromJson(response, null);
    } on ApiException catch (e) {
      return ApiResponse<T>.error(e.message, code: e.code ?? 500);
    } catch (e) {
      return ApiResponse<T>.error('请求失败: $e');
    }
  }
} 