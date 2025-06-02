import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/services/agent_service.dart';

class AiBotSettingPage extends StatefulWidget {
  const AiBotSettingPage({super.key});

  @override
  State<AiBotSettingPage> createState() => _AiBotSettingPageState();
}

class _AiBotSettingPageState extends State<AiBotSettingPage> {
  final AgentService _agentService = AgentService();
  List<AgentModel> _agentList = [];
  AgentModel? _selectedAgent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
          // 如果有数据，默认选择第一个
          if (_agentList.isNotEmpty) {
            _selectedAgent = _agentList.first;
          }
        });
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
    // 这里可以添加保存用户选择的逻辑
  }

  // 编辑智能体
  void _editAgent(AgentModel agent) {
    // TODO: 实现编辑智能体的功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑智能体: ${agent.agentName}')),
    );
  }

  // 添加新的智能体
  void _addNewAgent() {
    // TODO: 实现添加新智能体的功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加新智能体')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI设置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _agentList.length,
                    itemBuilder: (context, index) {
                      final agent = _agentList[index];
                      final isSelected = _selectedAgent?.id == agent.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // AI名称和选择状态
                            ListTile(
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFF3C8BFF) : Colors.grey.shade300,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              title: Text(
                                agent.agentName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editAgent(agent),
                              ),
                              onTap: () => _updateSelectedAgent(agent),
                            ),
                            
                            // AI详细信息
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 60,
                                right: 16,
                                bottom: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              '身份：',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              '心理教师',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              '音色：',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              agent.agentName.contains('男') ? '阳光男声' : '温柔女声',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
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
                    },
                  ),
                ),
                
                // 底部添加按钮
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _addNewAgent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C8BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '添加AI',
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
} 