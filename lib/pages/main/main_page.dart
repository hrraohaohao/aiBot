import 'package:flutter/material.dart';
import '../../http/services/user_service.dart';
import '../../utils/user_manager.dart';
import '../../utils/event_bus.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 当前选中的标签页索引
  int _currentIndex = 0;
  
  // 用户服务和用户管理器
  final UserService _userService = UserService();
  final UserManager _userManager = UserManager();
  
  // 事件订阅
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    
    // 初始化
    _init();
    
    // 监听未授权事件
    _subscription = EventBus.instance.on.listen((event) {
      if (event is UnauthorizedEvent && mounted) {
        debugPrint('MainPage 收到未授权事件: ${event.message}');
        
        // 显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录已过期: ${event.message}')),
        );
        
        // 跳转到登录页
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }
  
  @override
  void dispose() {
    // 取消事件订阅
    _subscription.cancel();
    super.dispose();
  }
  
  // 初始化方法
  Future<void> _init() async {
    // 初始化服务
    _userService.init();
    await _userManager.init();
    
    // 主动获取并保存用户信息
    _loadUserInfo();
  }
  
  // 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      debugPrint('MainPage: 开始获取用户信息...');
      final response = await _userService.getUserInfo();
      
      if (response.success && response.data != null) {
        debugPrint('MainPage: 获取用户信息成功，准备保存');
        
        // 保存用户信息到本地
        await _userManager.saveUserInfo(response.data!);
        
        // 验证保存结果
        final savedUser = _userManager.userInfo;
        debugPrint('MainPage: 用户信息保存结果: ${savedUser != null ? '成功' : '失败'}, username=${savedUser?.username ?? '未知'}');
      }
    } catch (e) {
      debugPrint('MainPage: 获取用户信息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          // 首页Tab
          HomeTab(),
          // 个人中心Tab
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '小Xin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        selectedItemColor: const Color(0xFF3C8BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
