import 'api_service.dart';
import '../models/api_response.dart';

class UserService extends ApiService {
  // 单例模式
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // API端点
  static const String _baseUrl = 'https://admin.chat-ai.cc';
  static const String _userRegister = '/xiaozhi/user/register'; //用户注册

  // 初始化
  Future<void> init() async {
    setBaseUrl(_baseUrl);
    // 可以在这里添加其他初始化步骤，如读取本地token并设置
  }

  Future<ApiResponse<String>> userRegister({
    required String username,
    required String password,
    required String captcha,
    required String captchaId,
  }) async {
    final Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'captcha': captcha,
      'captchaId': captchaId,
    };
    final response = await post<String>(
      _userRegister,
      data: data,
      fromJson: (json) => json.toString(),
    );
    return response;
  }
} 