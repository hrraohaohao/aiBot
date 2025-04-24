import 'package:flutter/material.dart';
import 'login_controller.dart';

class SetPasswordPage extends StatefulWidget {
  final String phoneNumber;
  
  const SetPasswordPage({
    super.key, 
    required this.phoneNumber,
  });

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final LoginController _controller = LoginController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;
  
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
    
    if (password.length != 8) {
      setState(() {
        _passwordError = '密码必须为8位';
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
      // 模拟注册请求
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // 注册成功，返回登录页并显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功，请登录')),
        );
        
        // 返回到登录页面（清除导航栈）
        Navigator.of(context).popUntil((route) => route.isFirst);
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
                  '设置密码',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '请为账号 ${widget.phoneNumber} 设置登录密码',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // 密码输入框
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _passwordError != null ? Colors.red : Colors.grey.shade300
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '请输入8位密码',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
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
              
              // 密码错误提示
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 确认密码输入框
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _confirmPasswordError != null ? Colors.red : Colors.grey.shade300
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: '请再次输入密码',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (_) {
                    // 输入变化时清除错误
                    if (_confirmPasswordError != null) {
                      setState(() {
                        _confirmPasswordError = null;
                      });
                    }
                  },
                ),
              ),
              
              // 确认密码错误提示
              if (_confirmPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: Text(
                    _confirmPasswordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // 完成按钮
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          '完成',
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