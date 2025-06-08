import 'package:ai_bot/http/services/agent_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../http/models/agent_model.dart';
import '../../../http/models/device_model.dart';
import '../../../pages/agent/aibot_setting_page.dart';
import '../../../pages/device/bot_manager_page.dart';
import '../../agent/agent_manager_page.dart';

// 菜单项类型枚举
enum MenuItemType {
  agent,
  manage,
}

// 菜单项包装类
class MenuItem {
  final MenuItemType type;
  final AgentModel? agent;
  
  MenuItem.agent(this.agent) : type = MenuItemType.agent;
  MenuItem.manage() : agent = null, type = MenuItemType.manage;
}

// 设备状态枚举
enum DeviceStatus {
  online,    // 在线
  offline,   // 离线
  charging,  // 充电中
  noNetwork, // 无网络连接
}

// 设备状态扩展
extension DeviceStatusExtension on DeviceStatus {
  String get text {
    switch (this) {
      case DeviceStatus.online:
        return '在线';
      case DeviceStatus.offline:
        return '离线';
      case DeviceStatus.charging:
        return '充电中';
      case DeviceStatus.noNetwork:
        return '无网络连接';
    }
  }
  
  Color get color {
    switch (this) {
      case DeviceStatus.online:
        return Colors.green;
      case DeviceStatus.offline:
        return Colors.grey;
      case DeviceStatus.charging:
        return Colors.orange;
      case DeviceStatus.noNetwork:
        return Colors.blue;
    }
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // 用户服务
  final AgentService _agentService = AgentService();

  // 智能体列表
  List<AgentModel> _agentList = [];

  // 当前选中的智能体
  AgentModel? _selectedAgent;

  // 是否正在加载
  bool _isLoading = true;

  // 是否有机器人
  final bool _hasRobots = false;
  
  // 绑定的机器人列表
  List<DeviceModel> _bindBotList = [];

  // 输入控制器
  final TextEditingController _familyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _agentService.init();
    // 加载智能体列表
    _loadAgentList();
  }

  // 加载智能体列表
  Future<void> _loadAgentList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _agentService.getAgentList();

      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        setState(() {
          _agentList = response.data!;
          // 默认选择第一个智能体
          _selectedAgent = _agentList.first;
        });
        
        // 加载第一个智能体的绑定机器人列表
        if (_selectedAgent != null) {
          await _loadBindBotList(_selectedAgent!.id);
        }
      }
    } catch (e) {
      debugPrint('加载智能体列表失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 更新选中的智能体
  void _updateSelectedAgent(AgentModel agent) {
    setState(() {
      _selectedAgent = agent;
    });
    // 获取与该智能体绑定的机器人列表
    _loadBindBotList(agent.id);
  }

  // 加载绑定的机器人列表
  Future<void> _loadBindBotList(String agentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _agentService.getBindBotList(agentId: agentId);

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        setState(() {
          _bindBotList = response.data!;
        });
      } else {
        // 没有数据时显示空列表
        setState(() {
          _bindBotList = [];
        });
      }
    } catch (e) {
      debugPrint('加载绑定机器人列表失败: $e');
      
      // 发生异常时显示空列表
      setState(() {
        _bindBotList = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 创建智能体并刷新列表
  Future<void> _createAgent(String agentName) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 调用创建智能体接口
      final response = await _agentService.agent(agentName: agentName);
      
      if (response.success) {
        // 创建成功，显示提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('智能体创建成功')),
          );
        }
        
        // 刷新智能体列表
        await _loadAgentList();
      } else {
        // 创建失败，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败: ${response.message}')),
          );
        }
      }
    } catch (e) {
      // 发生异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _bindBotList.isNotEmpty
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
          // 左侧标题 - 添加下拉菜单
          PopupMenuButton<MenuItem>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabled: _agentList.isNotEmpty,
            onSelected: (MenuItem item) {
              if (item.type == MenuItemType.agent && item.agent != null) {
                _updateSelectedAgent(item.agent!);
              } else if (item.type == MenuItemType.manage) {
                _navigateToAgentManagement();
              }
            },
            itemBuilder: (context) {
              // 创建智能体列表选项
              List<PopupMenuItem<MenuItem>> items = _agentList.map((agent) {
                return PopupMenuItem<MenuItem>(
                  value: MenuItem.agent(agent),
                  child: Row(
                    children: [
                      // 智能体图标
                      Image.asset(
                        'assets/images/icon_home.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      // 智能体名称
                      Text(
                        agent.agentName,
                        style: TextStyle(
                          fontWeight: _selectedAgent?.id == agent.id
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
              
              // 添加"智能体管理"选项
              if (_agentList.isNotEmpty) {
                items.add(
                  PopupMenuItem<MenuItem>(
                    value: MenuItem.manage(),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/icon_bot_set.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 4),
                        const Text('智能体管理'),
                      ],
                    ),
                  ),
                );
              }
              
              return items;
            },
            child: Row(
              children: [
                Text(
                  _isLoading ? '加载中...' : _selectedAgent?.agentName ?? '暂无智能体',
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
          ),

          // 右侧添加按钮
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // 显示新建智能体对话框
              _showCreateFamilyDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showCreateFamilyDialog() {
    _familyNameController.clear();
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部不关闭
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        '添加智能体',
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
                        hintText: '请输入智能体名称',
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
                            onPressed: isCreating 
                                ? null 
                                : () {
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
                            onPressed: isCreating 
                                ? null 
                                : () async {
                                    final agentName = _familyNameController.text.trim();
                                    if (agentName.isNotEmpty) {
                                      // 设置加载状态
                                      setState(() {
                                        isCreating = true;
                                      });
                                      
                                      // 关闭对话框
                                      Navigator.of(context).pop();
                                      
                                      // 创建智能体
                                      await _createAgent(agentName);
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
                            child: isCreating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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
          }
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
              color: Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 20),

          // 添加按钮 - 修改为跳转到设备管理页面
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedAgent != null) {
                  // 跳转到设备管理页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BotManagerPage(
                        agentId: _selectedAgent!.id,
                        agentName: _selectedAgent!.agentName,
                      ),
                    ),
                  ).then((result) {
                    // 如果返回结果为true，表示数据已更改，需要刷新
                    if (result == true && _selectedAgent != null) {
                      _loadBindBotList(_selectedAgent!.id);
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请先选择或创建一个智能体')),
                  );
                }
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
                '添加设备',
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

  // 获取随机设备状态（仅用于模拟）
  DeviceStatus _getDeviceStatus(int index) {
    // 使用固定的状态来对应图片中的四种状态
    switch (index % 4) {
      case 0:
        return DeviceStatus.charging;
      case 1:
        return DeviceStatus.offline;
      case 2:
        return DeviceStatus.online;
      case 3:
        return DeviceStatus.noNetwork;
      default:
        return DeviceStatus.offline;
    }
  }

  // 构建机器人列表
  Widget _buildRobotList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 每行两个
        childAspectRatio: 1.0, // 宽高比
        crossAxisSpacing: 16, // 水平间距
        mainAxisSpacing: 16, // 垂直间距
      ),
      itemCount: _bindBotList.length,
      itemBuilder: (context, index) {
        final bot = _bindBotList[index];
        final status = _getDeviceStatus(index);
        
        return GestureDetector(
          onTap: () {
            // 跳转到设备管理页面
            if (_selectedAgent != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BotManagerPage(
                    agentId: _selectedAgent!.id,
                    agentName: _selectedAgent!.agentName,
                  ),
                ),
              ).then((result) {
                // 如果返回结果为true，表示数据已更改，需要刷新
                if (result == true && _selectedAgent != null) {
                  _loadBindBotList(_selectedAgent!.id);
                }
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 设备名称和状态
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '面包板新版接线',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 机器人图片（不再居中，而是靠右）
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Image.asset(
                        'assets/images/icon_bot_online.png',
                        width: 75,
                        height: 58,
                      ),
                    ),
                  ),
                ),
                
                // 如果是在线状态，显示提醒消息
                if (status == DeviceStatus.online)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEEDED),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '2条新的警告',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF25B5B),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToAgentManagement() {
    // 跳转到智能体管理页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AgentManagerPage(),
      ),
    ).then((_) {
      // 从智能体管理页面返回时刷新数据
      _loadAgentList();
    });
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
