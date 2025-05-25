import 'package:flutter/material.dart';
import 'dart:async';

class BotConnectPage extends StatefulWidget {
  const BotConnectPage({super.key});

  @override
  State<BotConnectPage> createState() => _BotConnectPageState();
}

class _BotConnectPageState extends State<BotConnectPage> {
  // 搜索状态
  bool _isSearching = true;
  
  // 模拟的机器人列表
  final List<String> _botList = [
    'XiaoXin- E61A',
    'XiaoXin- E61A',
    'XiaoXin- E61A',
    'XiaoXin- E61A',
  ];
  
  // 选中的机器人索引
  int _selectedBotIndex = 1;
  
  // 动画点的数量 (1-3)
  int _dotCount = 0;
  Timer? _dotTimer;
  
  @override
  void initState() {
    super.initState();
    // 启动点动画定时器
    _startDotAnimation();
  }
  
  @override
  void dispose() {
    // 清理定时器
    _dotTimer?.cancel();
    super.dispose();
  }
  
  // 启动点动画
  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4; // 0,1,2,3循环
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '添加机器人',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _refreshSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索状态提示
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: _isSearching 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 固定文本部分
                      const Text(
                        '正在寻找小Xin',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      // 动态点部分 - 设置固定宽度，防止文本跳动
                      SizedBox(
                        width: 24, // 足够放下三个点的宽度
                        child: Text(
                          '.' * _dotCount,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Text(
                    '请选择要连接的设备',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
            ),
          ),
          
          // 机器人列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _botList.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedBotIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBotIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFDCEBFF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF3C8BFF) 
                            : const Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _botList[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected 
                                ? const Color(0xFF3C8BFF) 
                                : Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF3C8BFF),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 连接按钮
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _connectToBot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C8BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '连接',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          // iPhone底部安全区域指示条
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ],
      ),
    );
  }

  // 刷新搜索
  void _refreshSearch() {
    setState(() {
      _isSearching = true;
      _dotCount = 0; // 重置点动画
    });
    
    // 模拟搜索过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }
  
  // 连接到机器人
  void _connectToBot() {
    if (_selectedBotIndex >= 0 && _selectedBotIndex < _botList.length) {
      final selectedBot = _botList[_selectedBotIndex];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正在连接: $selectedBot')),
      );
      
      // TODO: 实现实际的连接逻辑
      
      // 连接成功后返回
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop(true); // 返回true表示连接成功
      });
    }
  }
} 