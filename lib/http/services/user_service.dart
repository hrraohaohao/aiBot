import 'api_service.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';

class UserService extends ApiService {
  // 单例模式
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

  // API端点
  static const String _baseUrl = 'https://admin.chat-ai.cc';
  static const String _userRegister = '/xiaozhi/mobile/user/register'; //用户注册
  static const String _userLogin = '/xiaozhi/mobile/user/login'; //用户登录
  static const String _smsVerification =
      '/xiaozhi/mobile/user/smsVerification'; //短信验证码
  static const String _smsVerify = '/xiaozhi/mobile/user/smsVerify'; //验证短信验证码
  static const String _retrievePassword =
      '/xiaozhi/mobile/user/retrieve-password'; //找回密码
  static const String _changePassword =
      '/xiaozhi/mobile/user/change-password'; //修改密码
  static const String _UserInfo = '/xiaozhi/mobile/user/info'; //用户信息

  // 初始化
  Future<void> init() async {
    setBaseUrl(_baseUrl);
    // 可以在这里添加其他初始化步骤，如读取本地token并设置
  }

  Future<ApiResponse<String>> userRegister({
    required String username,
    required String password,
    required String mobileCaptcha,
  }) async {
    final Map<String, dynamic> data = {
      'username': '+86$username',
      'password': password,
      'mobileCaptcha': mobileCaptcha,
    };
    final response = await post<String>(
      _userRegister,
      data: data,
      fromJson: (json) => json.toString(),
    );
    return response;
  }

  Future<ApiResponse<LoginResponse>> userLogin({
    required String username,
    required String password,
  }) async {
    final Map<String, dynamic> data = {
      'username': '+86$username',
      'password': password,
    };
    final response = await post<LoginResponse>(
      _userLogin,
      data: data,
      fromJson: (json) => LoginResponse.fromJson(json),
    );

    // 如果登录成功，立即设置token
    if (response.success && response.data != null) {
      setToken(response.data!.token);
    }

    return response;
  }

  // 发送短信验证码
  Future<ApiResponse<String>> sendSmsCode({
    required String phone,
  }) async {
    final Map<String, dynamic> data = {
      'phone': '+86$phone',
    };
    final response = await post<String>(
      _smsVerification,
      data: data,
      fromJson: (json) => json.toString(),
    );
    return response;
  }

  // 验证短信验证码
  Future<ApiResponse<String>> verifySmsCode({
    required String phone,
    required String mobileCaptcha,
  }) async {
    final Map<String, dynamic> data = {
      'username': '+86$phone',
      'mobileCaptcha': mobileCaptcha,
    };
    final response = await post<String>(_smsVerify,
        data: data, fromJson: (json) => json.toString());
    return response;
  }
}
