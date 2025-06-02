import 'package:flutter/material.dart';
import '../../../utils/token_manager.dart';
import '../../../utils/user_manager.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // 用户管理器
  final UserManager _userManager = UserManager();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            _buildAppBar(),
            
            // 主内容区域
            Expanded(
              child: SingleChildScrollView(
                child: _buildProfileContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建顶部标题栏
  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Text(
        '我的',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // 构建个人中心内容
  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ValueListenableBuilder(
              valueListenable: _userManager.userInfoNotifier,
              builder: (context, userInfo, _) {
                return Row(
                  children: [
                    // 头像
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade100,
                        image: userInfo?.avatar != null
                            ? DecorationImage(
                                image: NetworkImage(userInfo!.avatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: userInfo?.avatar == null
                          ? const Center(
                              child: Icon(
                                Icons.person,
                                size: 36,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 用户信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userInfo?.nickname ?? userInfo?.username ?? '未登录',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '账号: ${userInfo?.phone ?? userInfo?.username ?? '未知'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 编辑按钮
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        // TODO: 编辑个人信息
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 功能列表
          _buildSettingItem(
            icon: Icons.notifications_outlined, 
            title: '消息通知',
            onTap: () {
              // TODO: 进入消息通知页面
            }
          ),
          
          _buildSettingItem(
            icon: Icons.security_outlined, 
            title: '账号安全',
            onTap: () {
              // TODO: 进入账号安全页面
            }
          ),
          
          _buildSettingItem(
            icon: Icons.help_outline, 
            title: '帮助中心',
            onTap: () {
              // TODO: 进入帮助中心页面
            }
          ),
          
          _buildSettingItem(
            icon: Icons.settings_outlined, 
            title: '系统设置',
            onTap: () {
              // TODO: 进入系统设置页面
            }
          ),
          
          const SizedBox(height: 32),
          
          // 退出登录按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.red, width: 1),
                ),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey.shade700,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示退出登录确认对话框
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 清除token
              await TokenManager.clearToken();
              
              // 清除用户信息
              _userManager.clearUserInfo();
              
              if (mounted) {
                // 关闭对话框
                Navigator.of(context).pop();
                
                // 返回登录页面
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false, // 清除所有路由
                );
              }
            },
            child: const Text('确认退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 