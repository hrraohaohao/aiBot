import 'package:flutter/material.dart';
import '../../http/services/user_service.dart';
import '../../utils/token_manager.dart';

class LoginController {
  // 单例模式
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  LoginController._internal() {
    _initService();
  }
  
  // 登录状态
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  // 错误信息
  final ValueNotifier<String> errorMessage = ValueNotifier<String>('');
  // 用户服务
  late UserService _userService;
  
  // 初始化服务
  Future<void> _initService() async {
    _userService = UserService();
    await _userService.init();
  }
  
  // 显示协议条款
  void showTerms(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  // 登录
  Future<bool> login(String phone, String password) async {
    try {
      isLoading.value = true;
      
      // 调用登录接口
      final response = await _userService.userLogin(
        username: phone,
        password: password,
      );
      
      // 处理登录结果
      if (response.success && response.data != null) {
        final loginData = response.data!;
        
        // 保存token信息
        await TokenManager.saveToken(
          loginData.token,
          loginData.expire,
          loginData.clientHash,
        );
        
        return true;
      } else {
        // 登录失败
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      // 处理异常
      errorMessage.value = '登录失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
} 