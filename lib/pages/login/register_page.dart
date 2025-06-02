import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'login_controller.dart';
import '../../http/services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// 声明一个常量颜色，确保在整个文件中使用相同的颜色
const Color kPrimaryColor = Color(0xFF3C8BFF);

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final LoginController _controller = LoginController();
  final UserService _userService = UserService();
  bool _agreeTerms = false;
  bool _isLoading = false;
  bool _isInputValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateInput);
    _phoneController.dispose();
    super.dispose();
  }
  
  // 验证输入
  void _validateInput() {
    final phone = _phoneController.text.trim();
    final isValid = phone.isNotEmpty;
    
    if (isValid != _isInputValid) {
      setState(() {
        _isInputValid = isValid;
      });
    }
  }
  
  // 处理下一步
  Future<void> _handleNextStep() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请阅读并同意用户协议和隐私政策')),
      );
      return;
    }
    
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号')),
      );
      return;
    }
    
    // 手机号格式验证
    if (phone.length != 11 || !phone.startsWith('1')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的手机号')),
      );
      return;
    }
    
    // 显示加载中
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 调用真实的发送验证码API
      final response = await _userService.sendSmsCode(
        phone: phone,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (response.success) {
          // 导航到验证码页面
          Navigator.pushNamed(
            context, 
            '/verification',
            arguments: {'phone': phone}
          );
        } else {
          // 显示错误信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送验证码失败: $e')),
        );
      }
    }
  }
  
  // 返回登录页
  void _backToLogin() {
    Navigator.pop(context);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _backToLogin,
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, 你来啦~',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '未注册的手机号验证后自动登录',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 75),
                        
                        // 手机号输入框
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
                                  'assets/images/icon_iphone.png',
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
                      ],
                    ),
                  ),
                ),
                
                // 底部区域 - 包含按钮和协议
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 下一步按钮
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor.withOpacity(_isInputValid ? 1.0 : 0.5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
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
                                '下一步',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    
                    // 底部协议
                    Padding(
                      padding: const EdgeInsets.only(top: 28, bottom: 26, left: 47, right: 47),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Theme(
                            data: ThemeData(
                              checkboxTheme: CheckboxThemeData(
                                fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return kPrimaryColor;
                                  }
                                  return Colors.transparent;
                                }),
                                shape: const CircleBorder(),
                              ),
                            ),
                            child: Checkbox(
                              value: _agreeTerms,
                              side: const BorderSide(color: Color(0xFF999999)),
                              checkColor: Colors.white,
                              overlayColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => Colors.transparent
                              ),
                              splashRadius: 0,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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