import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../pages/device/bot_connect_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // 用户名称
  final String _userName = '饺子';
  // 是否有机器人
  final bool _hasRobots = false;
  // 输入控制器
  final TextEditingController _familyNameController = TextEditingController();
  
  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
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
                // 顶部标题栏
                _buildAppBar(),
                
                // 主内容区域
                Expanded(
                  child: _hasRobots 
                    ? _buildRobotList()
                    : _buildEmptyState(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建顶部标题栏
  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.transparent, // 改为透明，显示背景渐变
        boxShadow: [], // 移除阴影
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧标题
          Row(
            children: [
              Text(
                '$_userName的家庭',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
              ),
            ],
          ),
          
          // 右侧添加按钮
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // 显示新建家庭/班级对话框
              _showCreateFamilyDialog();
            },
          ),
        ],
      ),
    );
  }
  
  // 显示新建家庭/班级对话框
  void _showCreateFamilyDialog() {
    // 重置输入控制器
    _familyNameController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不关闭
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                const Center(
                  child: Text(
                    '新建家庭/班级',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 输入框
                TextField(
                  controller: _familyNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    hintText: '请输入家庭/班级名称',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 按钮区
                Row(
                  children: [
                    // 取消按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 确认按钮
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final familyName = _familyNameController.text.trim();
                          if (familyName.isNotEmpty) {
                            // TODO: 处理创建家庭/班级逻辑
                            print('创建家庭/班级: $familyName');
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C8BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '确认',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 机器人图标
          Container(
            width: 120,
            height: 120,
            child: CustomPaint(
              child: Center(
                child: Image.asset(
                  'assets/images/icon_bot_empty.png',
                  width: 119,
                  height: 93,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 文字提示
          const Text(
            '暂无机器人',
            style: TextStyle(
              fontSize: 16,
              color:const Color(0xFF333333),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 添加按钮
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // 导航到机器人连接页面
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BotConnectPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C8BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                '添加',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建机器人列表
  Widget _buildRobotList() {
    // TODO: 实现机器人列表
    return const Center(
      child: Text('机器人列表待实现'),
    );
  }
}

// 自定义虚线边框绘制器
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ));

    final Path dashPath = Path();
    
    // 计算周长
    final double perimeter = 2 * (size.width + size.height);
    final double dashCount = perimeter / (dashWidth + dashSpace);
    
    // 绘制虚线
    for (int i = 0; i < dashCount.floor(); i++) {
      final double start = i * (dashWidth + dashSpace);
      final double end = start + dashWidth;
      dashPath.addPath(
        extractPathUntilLength(path, start, end),
        Offset.zero,
      );
    }
    
    canvas.drawPath(dashPath, paint);
  }

  Path extractPathUntilLength(Path path, double start, double end) {
    final Path extracted = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      final double length = metric.length;
      if (start > length) {
        start -= length;
        end -= length;
      } else {
        extracted.addPath(
          metric.extractPath(start, end > length ? length : end),
          Offset.zero,
        );
        if (end > length) {
          end -= length;
          start = 0;
        } else {
          break;
        }
      }
    }
    return extracted;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 