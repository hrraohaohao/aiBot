import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/services/agent_service.dart';
import 'aibot_setting_page.dart';

class AgentManagerPage extends StatefulWidget {
  const AgentManagerPage({Key? key}) : super(key: key);

  @override
  State<AgentManagerPage> createState() => _AgentManagerPageState();
}

class _AgentManagerPageState extends State<AgentManagerPage> {
  // 智能体服务
  final AgentService _agentService = AgentService();
  
  // 智能体列表
  List<AgentModel> _agentList = [];
  
  // 是否正在加载
  bool _isLoading = true;
  
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
    // 跳转到智能体设置页面
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AiBotSettingPage()),
    ).then((_) {
      // 返回时刷新列表
      _loadAgentList();
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
            // TODO: 实现智能体详情页面跳转
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('查看智能体: ${agent.agentName}')),
            );
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
                    _buildInfoTag('${agent.deviceCount}个机器人', Icons.devices),
                    const SizedBox(width: 16),
                    _buildInfoTag('聊天记录', Icons.chat_bubble_outline),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建标签
  Widget _buildInfoTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 