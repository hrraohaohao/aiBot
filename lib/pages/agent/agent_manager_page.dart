import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/services/agent_service.dart';
import 'aibot_setting_page.dart';
import 'agent_setting_page.dart';
import 'chat_history_page.dart';

class AgentManagerPage extends StatefulWidget {
  const AgentManagerPage({Key? key}) : super(key: key);

  @override
  State<AgentManagerPage> createState() => _AgentManagerPageState();
}

class _AgentManagerPageState extends State<AgentManagerPage> with WidgetsBindingObserver {
  // 智能体服务
  final AgentService _agentService = AgentService();
  
  // 智能体列表
  List<AgentModel> _agentList = [];
  
  // 是否正在加载
  bool _isLoading = true;
  
  // 输入控制器
  final TextEditingController _agentNameController = TextEditingController();
  
  // 焦点节点，用于检测页面获取焦点事件
  final FocusNode _pageFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _agentService.init();
    
    // 注册应用生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    
    // 监听焦点变化
    _pageFocusNode.addListener(_onFocusChange);
    
    // 加载智能体列表
    _loadAgentList();
  }
  
  // 焦点变化监听
  void _onFocusChange() {
    if (_pageFocusNode.hasFocus) {
      // 页面获得焦点时刷新数据
      _loadAgentList();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 路由依赖变化时（如返回到此页面）刷新数据
    _loadAgentList();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 应用从后台恢复到前台时刷新数据
      _loadAgentList();
    }
  }
  
  // 加载智能体列表
  Future<void> _loadAgentList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _agentService.getAgentList();

      if (response.success && response.data != null) {
        setState(() {
          _agentList = response.data!;
        });
      } else {
        setState(() {
          _agentList = [];
        });
      }
    } catch (e) {
      debugPrint('加载智能体列表失败: $e');
      setState(() {
        _agentList = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 创建新智能体
  void _createNewAgent() {
    // 显示新建智能体对话框
    _showCreateAgentDialog();
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
  
  void _showCreateAgentDialog() {
    _agentNameController.clear();
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
                      controller: _agentNameController,
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
                                    final agentName = _agentNameController.text.trim();
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
  
  @override
  void dispose() {
    // 释放资源
    _agentNameController.dispose();
    _pageFocusNode.removeListener(_onFocusChange);
    _pageFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _pageFocusNode,
      child: Scaffold(
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
            '智能体管理',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            // 添加按钮
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
              onPressed: _createNewAgent,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _agentList.isEmpty
                ? _buildEmptyState()
                : _buildAgentList(),
      ),
    );
  }
  
  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/icon_bot_empty.png',
            width: 119,
            height: 93,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无智能体',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          // 添加智能体按钮
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _createNewAgent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C8BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                '添加智能体',
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
  
  // 构建智能体列表
  Widget _buildAgentList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _agentList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final agent = _agentList[index];
        return _buildAgentItem(agent);
      },
    );
  }
  
  // 构建智能体列表项
  Widget _buildAgentItem(AgentModel agent) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // 跳转到AI配置页面，传递智能体ID
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AgentSettingPage(agentId: agent.id),
              ),
            ).then((result) {
              // 从配置页面返回时，如果数据有变更则刷新列表
              if (result == true) {
                _loadAgentList();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      agent.agentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 统计信息行
                Row(
                  children: [
                    _buildDeviceCountTag(agent),
                    // 暂时隐藏聊天记录组件
                    // const SizedBox(width: 16),
                    // _buildChatHistoryTag(agent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建设备数量标签
  Widget _buildDeviceCountTag(AgentModel agent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.devices,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '${agent.deviceCount}个机器人',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建聊天记录标签（可点击）
  Widget _buildChatHistoryTag(AgentModel agent) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatHistoryPage(
              agentId: agent.id,
              agentName: agent.agentName,
              macAddress: '', // 从管理页面进入时使用空字符串作为默认值
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 14,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            const Text(
              '聊天记录',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 