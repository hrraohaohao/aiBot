import 'package:flutter/material.dart';
import '../../../utils/token_manager.dart';
import '../../../utils/user_manager.dart';
import '../../../pages/agent/agent_manager_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // 用户管理器
  final UserManager _userManager = UserManager();
  
  @override
  void initState() {
    super.initState();
    // 初始化用户管理器并打印调试信息
    _userManager.init().then((_) {
      // 打印用户信息，检查是否正确加载
      final userInfo = _userManager.userInfo;
      debugPrint('用户信息加载完成: ${userInfo?.username ?? '未知'}');
      if (mounted) {
        setState(() {}); // 触发重建
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // 获取屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;
    final gradientHeight = screenHeight / 3; // 渐变高度为屏幕的1/3
    
    return Scaffold(
      backgroundColor: Colors.transparent, // 设置为透明，以便显示渐变背景
      body: Stack(
        children: [
          // 渐变背景层
          Positioned.fill(
            child: Column(
              children: [
                // 顶部渐变部分 - 占1/3高度
                Container(
                  height: gradientHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFACCDFF), Colors.white],
                    ),
                  ),
                ),
                // 底部白色部分 - 占2/3高度
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 内容层
          SafeArea(
            child: Column(
              children: [
                // 顶部用户信息
                _buildUserHeader(),
                
                // 主内容区域
                Expanded(
                  child: Stack(
                    children: [
                      // 功能列表
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 智能体管理
                            _buildSettingItem(
                              icon: Icons.smart_toy_outlined, 
                              title: '智能体管理',
                              onTap: () {
                                // 跳转到智能体管理页面
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AgentManagerPage(),
                                  ),
                                );
                              }
                            ),
                            
                            // WiFi配网
                            _buildSettingItem(
                              icon: Icons.wifi, 
                              title: 'WiFi配网',
                              onTap: () {
                                // 跳转到WiFi配网页面
                                Navigator.of(context).pushNamed('/wifi_config');
                              }
                            ),
                          ],
                        ),
                      ),
                      
                      // 退出登录按钮 - 固定在底部
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            _showLogoutConfirmation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C8BFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            '退出登录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }
  
  // 构建顶部用户信息
  Widget _buildUserHeader() {
    return ValueListenableBuilder(
      valueListenable: _userManager.userInfoNotifier,
      builder: (context, userInfo, _) {
        // 调试信息
        debugPrint('构建用户信息: userInfo=${userInfo != null ? 'username=${userInfo.username}' : 'null'}');
        
        // 获取手机号，如果没有则显示"未知"
        String phoneNumber = '未知';
        String nickname = '未知用户';
        
        if (userInfo != null) {
          nickname = userInfo.username;
          
          // 从username中提取手机号，假设格式为+86XXXXXXXXXXX
          final username = userInfo.username;
          if (username.isNotEmpty) {
            if (username.startsWith('+86') && username.length > 3) {
              phoneNumber = username.substring(3); // 去掉+86前缀
            } else {
              phoneNumber = username;
            }
          }
        }
        
        // 手机号码脱敏显示
        final maskedPhone = _maskPhoneNumber(phoneNumber);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            color: Colors.transparent, // 保持透明以显示渐变背景
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                maskedPhone,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 手机号码脱敏处理
  String _maskPhoneNumber(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
  
  // 构建选项卡片
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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