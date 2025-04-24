import 'api_service.dart';
import '../models/api_response.dart';

// 用户模型示例
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class UserService extends ApiService {
  // 单例模式
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // API端点
  static const String _baseUrl = 'https://api.example.com';
  static const String _getUsersEndpoint = '/users';
  static const String _getUserEndpoint = '/users/{id}';
  static const String _createUserEndpoint = '/users';
  static const String _updateUserEndpoint = '/users/{id}';
  static const String _deleteUserEndpoint = '/users/{id}';

  // 初始化
  Future<void> init() async {
    setBaseUrl(_baseUrl);
    // 可以在这里添加其他初始化步骤，如读取本地token并设置
  }

  // 获取用户列表
  Future<ApiResponse<List<User>>> getUsers() async {
    final response = await get<List<User>>(
      _getUsersEndpoint,
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    return response;
  }

  // 获取单个用户
  Future<ApiResponse<User>> getUser(int id) async {
    final endpoint = _getUserEndpoint.replaceAll('{id}', id.toString());
    final response = await get<User>(
      endpoint,
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  // 创建用户
  Future<ApiResponse<User>> createUser(User user) async {
    final response = await post<User>(
      _createUserEndpoint,
      data: user.toJson(),
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  // 更新用户
  Future<ApiResponse<User>> updateUser(User user) async {
    final endpoint = _updateUserEndpoint.replaceAll('{id}', user.id.toString());
    final response = await put<User>(
      endpoint,
      data: user.toJson(),
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
    return response;
  }

  // 删除用户
  Future<ApiResponse<bool>> deleteUser(int id) async {
    final endpoint = _deleteUserEndpoint.replaceAll('{id}', id.toString());
    final response = await delete<bool>(
      endpoint,
      fromJson: (json) => true,
    );
    return response;
  }
} 