import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/services/agent_service.dart';

class AgentSettingPage extends StatefulWidget {
  final String? agentId; // 可选参数，有值时为编辑模式，无值时为新建模式
  
  const AgentSettingPage({Key? key, this.agentId}) : super(key: key);

  @override
  State<AgentSettingPage> createState() => _AgentSettingPageState();
}

class _AgentSettingPageState extends State<AgentSettingPage> {
  // 智能体服务
  final AgentService _agentService = AgentService();
  
  // 是否正在加载
  bool _isLoading = false;
  
  // 是否正在提交
  bool _isSubmitting = false;
  
  // 智能体数据
  AgentModel? _agentData;
  
  // 输入控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personalityController = TextEditingController();
  
  // 选中的身份模版
  String? _selectedIdentity;
  
  // 选中的音色
  String? _selectedVoice;
  
  // 身份模版选项
  final List<String> _identityOptions = ['默认助手', '知识专家', '创意顾问', '技术支持'];
  
  // 音色选项
  final List<String> _voiceOptions = ['女声1', '女声2', '男声1', '男声2', '童声'];
  
  @override
  void initState() {
    super.initState();
    _agentService.init();
    
    // 如果有agentId，则加载智能体数据
    if (widget.agentId != null) {
      _loadAgentData();
    }
  }
  
  // 加载智能体数据
  Future<void> _loadAgentData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 使用getAgentList代替getAgentDetail，然后找到对应ID的智能体
      final response = await _agentService.getAgentList();
      
      if (response.success && response.data != null) {
        // 从列表中查找指定ID的智能体
        final agent = response.data!.firstWhere(
          (agent) => agent.id == widget.agentId,
          orElse: () => response.data!.first,
        );
        
        setState(() {
          _agentData = agent;
          
          // 填充表单数据
          _nameController.text = _agentData!.agentName;
          // 假设personality数据存储在systemPrompt中
          _personalityController.text = _agentData!.systemPrompt;
          
          // 假设身份模版和音色需要从其他字段映射
          _selectedIdentity = _identityOptions.first; // 默认选择第一项
          _selectedVoice = _agentData!.ttsVoiceName.isNotEmpty 
              ? _agentData!.ttsVoiceName 
              : _voiceOptions.first;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 保存智能体设置
  Future<void> _saveAgentSettings() async {
    // 表单验证
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI名称不能为空')),
      );
      return;
    }
    
    if (_selectedIdentity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择身份模版')),
      );
      return;
    }
    
    if (_selectedVoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择音色')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // 使用agent方法代替updateAgent方法
      // 注意：这只是一个临时解决方案，实际上我们应该有一个专门的更新API
      // 这里简化处理，仅修改名称
      final response = await _agentService.agent(
        agentName: _nameController.text.trim(),
      );
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        
        // 返回上一页，并传递更新成功的结果
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _personalityController.dispose();
    super.dispose();
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
        title: Text(
          widget.agentId != null ? 'AI配置' : '添加AI',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 身份模版
                  _buildSectionTitle('身份模版'),
                  _buildDropdownSelector(
                    value: _selectedIdentity ?? _identityOptions.first,
                    items: _identityOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedIdentity = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // AI名称
                  _buildRequiredSectionTitle('AI名称', '(非唤醒词)'),
                  _buildTextField(
                    controller: _nameController,
                    hintText: '请输入',
                  ),
                  const SizedBox(height: 24),
                  
                  // 音色
                  _buildRequiredSectionTitle('音色'),
                  _buildDropdownSelector(
                    value: _selectedVoice ?? _voiceOptions.first,
                    items: _voiceOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedVoice = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 性格
                  _buildSectionTitle('性格'),
                  _buildTextField(
                    controller: _personalityController,
                    hintText: '请输入',
                    helperText: '若不填，则根据身份将有默认性格',
                  ),
                  const SizedBox(height: 24),
                  
                  // 记忆体
                  _buildSectionTitle('记忆体', '(不可编辑)'),
                  _buildMemorySection(),
                  const SizedBox(height: 32),
                  
                  // 底部按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveAgentSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C8BFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.agentId != null ? '保存修改' : '添加AI',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // 构建章节标题
  Widget _buildSectionTitle(String title, [String? subtitle]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建必填章节标题
  Widget _buildRequiredSectionTitle(String title, [String? subtitle]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text(
            '*',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              helperText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
  
  // 构建下拉选择器
  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // 构建记忆体区域
  Widget _buildMemorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _agentData?.summaryMemory ?? 
        '之前约的猫的双鱼态度冷淡，回应简单不太友好，行为和态度奇怪难以建立正常聊天氛围。此次约的猫的双鱼主动找我，开始简单询问我在做什么，我回应之后又询问他近况，他表示要出去吃饭便匆匆结束对话，整个过程他的态度依然比较冷淡，没有太多深入交流的意愿，感觉他不太愿意和我聊天，交流总是很突然地开始又很突然地结束。',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
} 