import 'package:flutter/material.dart';
import 'login_controller.dart';
import '../../http/services/user_service.dart';

class SetPasswordPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationCode;
  
  const SetPasswordPage({
    super.key, 
    required this.phoneNumber,
    required this.verificationCode,
  });

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

// 声明一个常量颜色，确保在整个文件中使用相同的颜色
const Color kPrimaryColor = Color(0xFF3C8BFF);

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final LoginController _controller = LoginController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isInputValid = false;
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateInput);
    _confirmPasswordController.addListener(_validateInput);
  }
  
  @override
  void dispose() {
    _passwordController.removeListener(_validateInput);
    _confirmPasswordController.removeListener(_validateInput);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // 检查输入是否有效
  void _validateInput() {
    final password = _passwordController.text;
    final isValid = password.isNotEmpty;
    
    if (isValid != _isInputValid) {
      setState(() {
        _isInputValid = isValid;
      });
    }
  }
  
  // 验证密码
  bool _validatePassword() {
    final password = _passwordController.text;
    
    if (password.isEmpty) {
      setState(() {
        _passwordError = '请输入密码';
      });
      return false;
    }
    
    if (password.length < 6 || password.length > 16) {
      setState(() {
        _passwordError = '密码长度应为6-16位';
      });
      return false;
    }
    
    setState(() {
      _passwordError = null;
    });
    return true;
  }
  
  // 验证确认密码
  bool _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = '请再次输入密码';
      });
      return false;
    }
    
    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = '两次输入的密码不一致';
      });
      return false;
    }
    
    setState(() {
      _confirmPasswordError = null;
    });
    return true;
  }
  
  // 完成注册
  Future<void> _handleRegister() async {
    // 清除错误信息
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });
    
    // 验证密码
    final isPasswordValid = _validatePassword();
    final isConfirmPasswordValid = _validateConfirmPassword();
    
    if (!isPasswordValid || !isConfirmPasswordValid) {
      return;
    }
    
    // 显示加载中
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 调用实际的注册接口
      final userService = UserService();
      await userService.init(); // 确保服务已初始化
      
      final response = await userService.userRegister(
        username: widget.phoneNumber,
        password: _passwordController.text,
        captcha: widget.verificationCode, // 使用从验证码页面传来的验证码
        captchaId: widget.phoneNumber, // 使用手机号作为captchaId
      );
      
      if (mounted) {
        if (response.success) {
          // 注册成功，返回登录页并显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('注册成功，请登录')),
          );
          
          // 返回到登录页面（清除导航栈）
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // 注册失败，显示错误信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('注册失败: ${response.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // 渐变背景
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF596BFF),
                  Color(0xFF6DA2FF),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 底部纯白色背景
          Positioned(
            top: MediaQuery.of(context).size.height * 0.7 - 1,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
            ),
          ),
          // 内容区域
          SafeArea(
            child: Column(
              children: [
                // 顶部内容区域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // 标题
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '设置密码',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '设置密码 完成注册',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // 密码输入框
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  child: Image.asset(
                                    _obscurePassword 
                                        ? 'assets/images/icon_password_hide.png'
                                        : 'assets/images/icon_password_show.png',
                                    width: 26,
                                    height: 26,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: const InputDecoration(
                                    hintText: '6-16位字母/数字/符号密码',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (_) {
                                    // 输入变化时清除错误
                                    if (_passwordError != null) {
                                      setState(() {
                                        _passwordError = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 密码错误提示
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 50, top: 8),
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // 底部区域 - 包含按钮
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 完成注册按钮
                    Container(
                      margin: const EdgeInsets.only(left: 40, right: 40, bottom: 88),
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isInputValid ? (_isLoading ? null : _handleRegister) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
                          disabledForegroundColor: Colors.white,
                        ),
                        child: _isLoading 
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '完成注册',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 