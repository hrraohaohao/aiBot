import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'login_controller.dart';
import '../../http/services/user_service.dart';

class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  
  const VerificationPage({
    super.key, 
    required this.phoneNumber,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

// 声明一个常量颜色，确保在整个文件中使用相同的颜色
const Color kPrimaryColor = Color(0xFF3C8BFF);

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6, (_) => TextEditingController()
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, (_) => FocusNode()
  );
  
  final LoginController _controller = LoginController();
  final UserService _userService = UserService();
  final FocusNode _containerFocusNode = FocusNode();
  
  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _startCountdown();
    
    // 为每个输入框配置控制器监听
    for (int i = 0; i < 6; i++) {
      final controller = _controllers[i];
      controller.addListener(() {
        // 监听文本变化
        final text = controller.text;
        
        // 如果输入了内容，自动跳到下一个框
        if (text.isNotEmpty && text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        
        // 检查是否所有格子都填满了
        if (_isCodeComplete && controller == _controllers.last) {
          _handleVerification();
        }
      });
    }

    // 自动聚焦第一个输入框
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _containerFocusNode.dispose();
    super.dispose();
  }
  
  // 开始倒计时
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }
  
  // 清空所有输入框
  void _clearInputs() {
    for (var controller in _controllers) {
      controller.clear();
    }
    // 聚焦到第一个输入框
    _focusNodes[0].requestFocus();
  }
  
  // 重新发送验证码
  void _resendCode() async {
    if (_countdown > 0) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // 调用真实API发送验证码
      final response = await _userService.sendSmsCode(
        phone: widget.phoneNumber,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (response.success) {
        setState(() {
          _countdown = 60;
          _startCountdown();
        });
        
        // 清空所有输入框
        _clearInputs();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('验证码已重新发送')),
        );
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '发送验证码失败: $e';
      });
    }
  }
  
  // 验证码是否已全部填写
  bool get _isCodeComplete {
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }
  
  // 获取完整验证码
  String get _fullCode {
    return _controllers.map((c) => c.text).join();
  }
  
  // 处理验证码确认
  Future<void> _handleVerification() async {
    if (!_isCodeComplete) {
      setState(() {
        _hasError = true;
        _errorMessage = '请输入完整的验证码';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final response = await _userService.verifySmsCode(
        phone: widget.phoneNumber,
        mobileCaptcha: _fullCode,
      );
      
      if (response.success) {
        if (mounted) {
          // 导航到设置密码页面，同时传递电话号码和验证码
          Navigator.pushNamed(
            context, 
            '/set_password',
            arguments: {
              'phone': widget.phoneNumber,
              'verificationCode': _fullCode
            }
          );
        }
      } else {
        // 验证失败
        setState(() {
          _hasError = true;
          _errorMessage = response.message.isNotEmpty 
              ? response.message 
              : '验证码错误，请重新输入';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = '验证失败: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 验证码输入框UI部分
  Widget _buildVerificationInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RawKeyboardListener(
        focusNode: _containerFocusNode,
        onKey: (RawKeyEvent event) {
          // 检测到删除键
          if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            // 找到当前焦点所在的输入框
            for (int i = 0; i < 6; i++) {
              if (_focusNodes[i].hasFocus) {
                // 如果当前输入框为空且不是第一个，则跳转到前一个输入框
                if (_controllers[i].text.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                  _controllers[i - 1].text = '';
                  break;
                }
              }
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 46,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  maxLength: 1,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // 如果清空了输入框，且不是第一个输入框，则返回上一个
                    if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                  // 限制只能输入数字
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
                                '输入验证码',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '我们已向 +${widget.phoneNumber} 发送验证码',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const Text(
                                '请查看短信并输入验证码',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // 验证码输入框
                        _buildVerificationInputs(),
                      ],
                    ),
                  ),
                ),
                
                // 底部区域 - 包含错误提示和按钮
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 验证码输入错误提示 - 只在有错误时显示
                    if (_hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    
                    // 重新发送按钮（60s倒计时）
                    Container(
                      margin: const EdgeInsets.only(left: 40, right: 40, bottom: 88),
                      height: 52,
                      child: _countdown > 0
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor.withOpacity(0.5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
                                disabledForegroundColor: Colors.white,
                              ),
                              child: Text(
                                '重新发送 (${_countdown}s)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _resendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                '重新发送验证码',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 