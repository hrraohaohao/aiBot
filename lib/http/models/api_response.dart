class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final bool success;

  ApiResponse({
    this.code = 200,
    required this.message,
    this.data,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? dataFromJson) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && dataFromJson != null ? dataFromJson(json['data']) : null,
      success: json['code'] == 200 || json['code'] == 0, // 根据实际API规范调整
    );
  }

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(
      code: 200,
      message: '成功',
      data: data,
      success: true,
    );
  }

  factory ApiResponse.error(String message, {int code = 500, T? data}) {
    return ApiResponse<T>(
      code: code,
      message: message,
      data: data,
      success: false,
    );
  }
} 