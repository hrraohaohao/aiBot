import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const HomeTab(),
    const ProfileTab(),
  ];

  // 底部导航项
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/images/icon_tab_bot.png')),
      label: '小Xin',
    ),
    const BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/images/icon_tab_mine.png')),
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedItemColor: const Color(0xFF3C8BFF),
        // 蓝色 - 选中颜色
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
