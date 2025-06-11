import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/models/agent_template_model.dart';
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
  
  // 角色模板列表
  List<AgentTemplateModel> _templateList = [];
  
  // 当前选中的模板
  AgentTemplateModel? _selectedTemplate;
  
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
    
    // 加载角色模板列表
    _loadTemplateList();
    
    // 如果有agentId，则加载智能体数据
    if (widget.agentId != null) {
      _loadAgentData();
    }
  }
  
  // 加载角色模板列表
  Future<void> _loadTemplateList() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _agentService.getAgentTemplateList();
      
      if (response.success && response.data != null) {
        setState(() {
          _templateList = response.data!;
          // 不自动选择模板，保持未选择状态
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载角色模板失败: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载角色模板失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 加载智能体数据
  Future<void> _loadAgentData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 使用getAgentDetail获取单个智能体详情
      final response = await _agentService.getAgentDetail(widget.agentId!);
      
      if (response.success && response.data != null) {
        setState(() {
          _agentData = response.data;
          
          // 填充表单数据
          _nameController.text = _agentData!.agentName;
          // 填充角色介绍
          _personalityController.text = _agentData!.systemPrompt;
          
          // 不自动匹配模板，保持未选择状态
          _selectedTemplate = null;
          _selectedIdentity = null;
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
  
  // 当角色模板变更时
  void _onTemplateChanged(String? templateName) {
    if (templateName == null) {
      setState(() {
        _selectedTemplate = null;
        _selectedIdentity = null;
        // 不自动填充角色介绍，保持当前内容
      });
      return;
    }
    
    // 查找对应的模板
    final template = _templateList.firstWhere(
      (template) => template.agentName == templateName,
      orElse: () => _templateList.first,
    );
    
    setState(() {
      _selectedTemplate = template;
      _selectedIdentity = template.agentName;
      
      // 更新角色介绍
      _personalityController.text = template.systemPrompt;
    });
  }
  
  // 保存智能体设置
  Future<void> _saveAgentSettings() async {
    // 表单验证
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('助手昵称不能为空')),
      );
      return;
    }
    
    // 不再强制要求选择角色模板
    
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
                  // 角色模版（原身份模版）
                  _buildSectionTitle('角色模版'),
                  _buildDropdownSelector(
                    value: _selectedIdentity,
                    items: _templateList.isEmpty 
                        ? _identityOptions 
                        : _templateList.map((template) => template.agentName).toList(),
                    onChanged: (value) {
                      _onTemplateChanged(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 助手昵称（原AI名称）
                  _buildRequiredSectionTitle('助手昵称', '(非唤醒词)'),
                  _buildTextField(
                    controller: _nameController,
                    hintText: '请输入',
                  ),
                  const SizedBox(height: 24),
                  
                  // 角色介绍（原性格）
                  _buildSectionTitle('角色介绍'),
                  _buildTextField(
                    controller: _personalityController,
                    hintText: '请输入',
                    helperText: '若不填，则根据角色将有默认性格',
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                  
                  // 记忆（原记忆体）
                  _buildSectionTitle('记忆', '(不可编辑)'),
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
    double? height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: height != null ? null : 1,
            expands: height != null,
            textAlignVertical: TextAlignVertical.top,
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
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
          hint: Text('请选择角色模板'),
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: onChanged,
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
        _agentData?.summaryMemory ?? '',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
} 