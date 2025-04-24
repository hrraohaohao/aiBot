import 'package:flutter/material.dart';
import 'dart:async';
import 'login_controller.dart';

class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  
  const VerificationPage({
    super.key, 
    required this.phoneNumber,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6, (_) => TextEditingController()
  );
  final List<FocusNode> _focusNodes = List.generate(
    6, (_) => FocusNode()
  );
  
  final LoginController _controller = LoginController();
  
  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startCountdown();
    
    // 监听焦点变化，自动跳转到下一个输入框
    for (int i = 0; i < 5; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.isNotEmpty) {
          _focusNodes[i + 1].requestFocus();
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
  
  // 重新发送验证码
  void _resendCode() {
    if (_countdown > 0) return;
    
    setState(() {
      _countdown = 60;
      _startCountdown();
    });
    
    // TODO: 调用发送验证码API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('验证码已重新发送')),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入完整的验证码')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 模拟验证码验证过程
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // 这里假设验证码始终正确，实际应用中应该调用API验证
        // 导航到设置密码页面
        Navigator.pushNamed(
          context, 
          '/set_password',
          arguments: {'phone': widget.phoneNumber}
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('验证失败: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  '验证手机号',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '验证码已发送至：${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // 验证码输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 45,
                      height: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22),
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            // 自动跳转到上一个输入框
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 重新发送按钮
              Center(
                child: TextButton(
                  onPressed: _countdown > 0 ? null : _resendCode,
                  child: Text(
                    _countdown > 0 ? '$_countdown秒后可重新发送' : '重新发送验证码',
                    style: TextStyle(
                      color: _countdown > 0 ? Colors.grey : Colors.blue,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 确认按钮
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerification,
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
                          '确认',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 