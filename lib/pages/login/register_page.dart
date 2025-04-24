import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'login_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final LoginController _controller = LoginController();
  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
      // 这里模拟发送验证码的网络请求
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // 导航到验证码页面
        Navigator.pushNamed(
          context, 
          '/verification',
          arguments: {'phone': phone}
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _backToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 顶部内容
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      const Center(
                        child: Text(
                          '注册小Xin账号',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // 手机号输入框
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '手机号',
                            contentPadding: EdgeInsets.symmetric(horizontal: 15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // 下一步按钮
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleNextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
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
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                  
                  // 底部协议
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: TextSpan(
                                text: '我已阅读并同意 ',
                                style: const TextStyle(color: Colors.black),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建链接文本
  TextSpan _buildLinkTextSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.blue,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }
} 