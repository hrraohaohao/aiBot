import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'login_controller.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _controller = LoginController();
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // 处理登录
  Future<void> _handleLogin() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请阅读并同意用户协议和隐私政策')),
      );
      return;
    }
    
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号')),
      );
      return;
    }
    
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入密码')),
      );
      return;
    }
    
    // 显示加载中
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 调用登录控制器
      final success = await _controller.login(phone, password);
      
      if (success) {
        // 登录成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录成功')),
          );
          // TODO: 导航到主页
        }
      } else {
        // 登录失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('用户名或密码错误')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $e')),
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
  
  // 处理注册
  void _handleRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
  
  // 显示用户协议
  void _showUserAgreement() {
    _controller.showTerms(
      context, 
      '用户协议', 
      '本协议是您与小Xin机器人之间关于使用本应用服务所订立的契约。请您仔细阅读本注册协议，如果您点击"同意"并完成注册，将视为您接受并愿意遵守本协议的所有规定。'
    );
  }
  
  // 显示隐私政策
  void _showPrivacyPolicy() {
    _controller.showTerms(
      context, 
      '隐私政策', 
      '我们非常重视您的个人信息和隐私保护。本隐私政策载明了我们如何收集、使用、储存和分享您的信息，以及您如何访问、更新、控制和保护您的信息。'
    );
  }
  
  // 显示未成年保护规则
  void _showChildProtection() {
    _controller.showTerms(
      context, 
      '未成年人个人信息保护规则', 
      '我们高度重视对未成年人个人信息的保护。如您为未成年人，建议您请您的父母或监护人阅读本规则，并在征得您父母或监护人同意的前提下使用我们的服务或向我们提供信息。'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 顶部内容区域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // 标题
                        const Center(
                          child: Text(
                            '欢迎使用小xin机器人',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // 中间图标区域
                        Container(
                          height: 200,
                          child: Center(
                            child: Image.asset(
                              'assets/images/icon_logo.png',
                              width: 274,
                              height: 274,
                            ),
                          ),
                        ),
                        
                        // 输入框区域
                        Container(
                          height: 52,
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
                                child: Image.asset(
                                  'assets/images/icon_ipone.png',
                                  width: 26,
                                  height: 26,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    hintText: '请输入手机号码',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
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
                                    hintText: '请输入密码',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 78),
                        
                        // 登录按钮
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3C8BFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
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
                                    '登录',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 底部协议 - 固定在底部
                Padding(
                  padding: const EdgeInsets.only(bottom: 26, left: 47, right: 47),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Theme(
                        data: ThemeData(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFF6979FF); // 选中时的填充色
                              }
                              return Colors.transparent; // 未选中时透明
                            }),
                          ),
                        ),
                        child: Checkbox(
                          value: _agreeTerms,
                          side: const BorderSide(color: Color(0xFF999999)), // 边框颜色改为蓝色
                          onChanged: (value) {
                            setState(() {
                              _agreeTerms = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: '我已阅读并同意 ',
                            style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                            children: [
                              _buildLinkTextSpan('《用户协议》', _showUserAgreement),
                              const TextSpan(text: '、'),
                              _buildLinkTextSpan('《隐私政策》', _showPrivacyPolicy),
                              const TextSpan(text: '、'),
                              _buildLinkTextSpan('《未成年人个人信息保护规则》', _showChildProtection),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建链接文本
  TextSpan _buildLinkTextSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFF6979FF),
        decoration: TextDecoration.underline,
        fontSize: 12,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }
} 