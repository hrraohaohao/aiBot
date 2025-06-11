import 'package:flutter/material.dart';
import '../../http/models/agent_model.dart';
import '../../http/models/agent_template_model.dart';
import '../../http/models/model_name_item.dart';
import '../../http/models/model_voice_item.dart';
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
  
  // 新增各模型选择
  String? _selectedVAD;
  String? _selectedASR;
  String? _selectedLLM;
  String? _selectedVLLM;
  String? _selectedIntent;
  String? _selectedMemory;
  String? _selectedTTS;
  String? _selectedVoice;
  
  // 上传类型选择
  String _uploadType = '上传文字'; // 默认值
  
  // 身份模版选项
  final List<String> _identityOptions = ['默认助手', '知识专家', '创意顾问', '技术支持'];
  
  // 模型选项
  final List<String> _vadOptions = ['VAD_SileroVAD', 'VAD_WebRTC'];
  final List<String> _asrOptions = ['ASR_SherpaASR', 'ASR_Whisper'];
  final List<String> _llmOptions = ['LLM_ChatGLM', 'LLM_LLaMA', 'LLM_Qwen'];
  final List<String> _vllmOptions = ['VLLM_ChatGLMVLLM', 'VLLM_LLaVA'];
  final List<String> _intentOptions = ['Intent_function_call', 'Intent_basic'];
  final List<String> _memoryOptions = ['Memory_mem_local_short', 'Memory_extended'];
  final List<String> _ttsOptions = ['TTS_HuoshanDoubleStreamTTS', 'TTS_Basic'];
  final List<String> _voiceOptions = ['女声1', '女声2', '男声1', '男声2', '童声'];
  final List<String> _uploadOptions = ['上传文字', '上传文字+语音'];
  
  // 模型列表
  List<ModelNameItem> _vadModelList = [];
  List<ModelNameItem> _asrModelList = [];
  List<ModelNameItem> _llmModelList = [];
  List<ModelNameItem> _vllmModelList = [];
  List<ModelNameItem> _intentModelList = [];
  List<ModelNameItem> _memoryModelList = [];
  List<ModelNameItem> _ttsModelList = [];
  List<ModelNameItem> _voiceModelList = [];
  
  // 音色列表
  List<ModelVoiceItem> _voiceModelItemList = [];
  
  @override
  void initState() {
    super.initState();
    _agentService.init();
    
    // 加载角色模板列表
    _loadTemplateList();
    
    // 加载模型列表
    _loadVadModelList();
    _loadAsrModelList();
    _loadLlmModelList();
    _loadVllmModelList();
    _loadIntentModelList();
    _loadMemoryModelList();
    _loadTtsModelList();
    
    // 默认加载音色列表（TTS_HuoshanDoubleStreamTTS）
    _loadVoiceModelList('TTS_HuoshanDoubleStreamTTS');
    
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
  
  // 加载VAD模型列表
  Future<void> _loadVadModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'VAD');
      
      if (response.success && response.data != null) {
        setState(() {
          _vadModelList = response.data!;
        });
      } else {
        debugPrint('加载VAD模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载VAD模型列表失败: $e');
    }
  }
  
  // 加载ASR模型列表
  Future<void> _loadAsrModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'ASR');
      
      if (response.success && response.data != null) {
        setState(() {
          _asrModelList = response.data!;
        });
      } else {
        debugPrint('加载ASR模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载ASR模型列表失败: $e');
    }
  }
  
  // 加载LLM模型列表
  Future<void> _loadLlmModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'LLM');
      
      if (response.success && response.data != null) {
        setState(() {
          _llmModelList = response.data!;
        });
      } else {
        debugPrint('加载LLM模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载LLM模型列表失败: $e');
    }
  }
  
  // 加载VLLM模型列表
  Future<void> _loadVllmModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'VLLM');
      
      if (response.success && response.data != null) {
        setState(() {
          _vllmModelList = response.data!;
        });
      } else {
        debugPrint('加载VLLM模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载VLLM模型列表失败: $e');
    }
  }
  
  // 加载Intent模型列表
  Future<void> _loadIntentModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'Intent');
      
      if (response.success && response.data != null) {
        setState(() {
          _intentModelList = response.data!;
        });
      } else {
        debugPrint('加载Intent模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载Intent模型列表失败: $e');
    }
  }
  
  // 加载Memory模型列表
  Future<void> _loadMemoryModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'Memory');
      
      if (response.success && response.data != null) {
        setState(() {
          _memoryModelList = response.data!;
        });
      } else {
        debugPrint('加载Memory模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载Memory模型列表失败: $e');
    }
  }
  
  // 加载TTS模型列表
  Future<void> _loadTtsModelList() async {
    try {
      final response = await _agentService.getModelsName(modelType: 'TTS');
      
      if (response.success && response.data != null) {
        setState(() {
          _ttsModelList = response.data!;
        });
      } else {
        debugPrint('加载TTS模型列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载TTS模型列表失败: $e');
    }
  }
  
  // 加载音色列表
  Future<void> _loadVoiceModelList(String modelId) async {
    try {
      final response = await _agentService.getModelVoices(modelId: modelId);
      
      if (response.success && response.data != null) {
        setState(() {
          _voiceModelItemList = response.data!;
          // 清除之前选择的音色，因为模型变了
          _selectedVoice = null;
        });
      } else {
        debugPrint('加载音色列表失败: ${response.message}');
      }
    } catch (e) {
      debugPrint('加载音色列表失败: $e');
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
          
          // 只填充已有的表单数据
          _nameController.text = _agentData!.agentName;
          // 填充角色介绍
          _personalityController.text = _agentData!.systemPrompt;
          
          // 暂时不填充模型相关字段，保持为空
          _selectedVAD = null;
          _selectedASR = null;
          _selectedLLM = null;
          _selectedVLLM = null;
          _selectedIntent = null;
          _selectedMemory = null;
          _selectedTTS = null;
          _selectedVoice = null;
          
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
  
  // 当语音合成(TTS)模型变更时
  void _onTtsModelChanged(String? modelId) {
    setState(() {
      _selectedTTS = modelId;
    });
    
    // 当TTS模型变更时，加载对应的音色列表
    if (modelId != null) {
      _loadVoiceModelList(modelId);
    }
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
      // 这里需要扩展agent方法，包含所有模型选项
      // 暂时只使用简化版本
      final response = await _agentService.agent(
        agentName: _nameController.text.trim(),
        // 以下参数需要在AgentService.agent方法中添加
        // vadModelId: _selectedVAD,
        // asrModelId: _selectedASR,
        // llmModelId: _selectedLLM,
        // vllmModelId: _selectedVLLM,
        // intentModelId: _selectedIntent,
        // memModelId: _selectedMemory,
        // ttsModelId: _selectedTTS,
        // ttsVoiceId: _selectedVoice,
        // systemPrompt: _personalityController.text,
        // uploadType: _uploadType,
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
                  const SizedBox(height: 24),
                  
                  // 以下是新增加的内容，放在记忆下面
                  
                  // 语音活动检测(VAD)
                  _buildSectionTitle('语音活动检测(VAD)'),
                  _buildDropdownSelector(
                    value: _selectedVAD,
                    items: _vadModelList.isEmpty 
                        ? _vadOptions 
                        : _vadModelList.map((model) => model.id).toList(),
                    itemLabels: _vadModelList.isEmpty 
                        ? null 
                        : _vadModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVAD = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 语音识别(ASR)
                  _buildSectionTitle('语音识别(ASR)'),
                  _buildDropdownSelector(
                    value: _selectedASR,
                    items: _asrModelList.isEmpty 
                        ? _asrOptions 
                        : _asrModelList.map((model) => model.id).toList(),
                    itemLabels: _asrModelList.isEmpty 
                        ? null 
                        : _asrModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedASR = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 大语言模型(LLM)
                  _buildSectionTitle('大语言模型(LLM)'),
                  _buildDropdownSelector(
                    value: _selectedLLM,
                    items: _llmModelList.isEmpty 
                        ? _llmOptions 
                        : _llmModelList.map((model) => model.id).toList(),
                    itemLabels: _llmModelList.isEmpty 
                        ? null 
                        : _llmModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLLM = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 视觉大模型(VLLM)
                  _buildSectionTitle('视觉大模型(VLLM)'),
                  _buildDropdownSelector(
                    value: _selectedVLLM,
                    items: _vllmModelList.isEmpty 
                        ? _vllmOptions 
                        : _vllmModelList.map((model) => model.id).toList(),
                    itemLabels: _vllmModelList.isEmpty 
                        ? null 
                        : _vllmModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVLLM = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 意图识别(Intent)
                  _buildSectionTitle('意图识别(Intent)'),
                  _buildDropdownSelector(
                    value: _selectedIntent,
                    items: _intentModelList.isEmpty 
                        ? _intentOptions 
                        : _intentModelList.map((model) => model.id).toList(),
                    itemLabels: _intentModelList.isEmpty 
                        ? null 
                        : _intentModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIntent = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 记忆(Memory)
                  _buildSectionTitle('记忆(Memory)'),
                  _buildDropdownSelector(
                    value: _selectedMemory,
                    items: _memoryModelList.isEmpty 
                        ? _memoryOptions 
                        : _memoryModelList.map((model) => model.id).toList(),
                    itemLabels: _memoryModelList.isEmpty 
                        ? null 
                        : _memoryModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMemory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 上传方式选择
                  Row(
                    children: _uploadOptions.map((option) {
                      return Expanded(
                        child: RadioListTile<String>(
                          title: Text(option, style: const TextStyle(fontSize: 14)),
                          value: option,
                          groupValue: _uploadType,
                          onChanged: (value) {
                            setState(() {
                              _uploadType = value!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 语音合成(TTS)
                  _buildSectionTitle('语音合成(TTS)'),
                  _buildDropdownSelector(
                    value: _selectedTTS,
                    items: _ttsModelList.isEmpty 
                        ? _ttsOptions 
                        : _ttsModelList.map((model) => model.id).toList(),
                    itemLabels: _ttsModelList.isEmpty 
                        ? null 
                        : _ttsModelList.map((model) => model.modelName).toList(),
                    onChanged: (value) {
                      _onTtsModelChanged(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 角色音色
                  _buildSectionTitle('角色音色'),
                  _buildDropdownSelector(
                    value: _selectedVoice,
                    items: _voiceModelItemList.isEmpty 
                        ? _voiceOptions 
                        : _voiceModelItemList.map((voice) => voice.id).toList(),
                    itemLabels: _voiceModelItemList.isEmpty 
                        ? null 
                        : _voiceModelItemList.map((voice) => voice.name).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVoice = value;
                      });
                    },
                  ),
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
    List<String>? itemLabels,
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
          hint: Text('请选择'),
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: onChanged,
          items: items.asMap().entries.map<DropdownMenuItem<String>>((entry) {
            final int index = entry.key;
            final String value = entry.value;
            final String label = itemLabels != null && index < itemLabels.length 
                ? itemLabels[index] 
                : value;
            
            return DropdownMenuItem<String>(
              value: value,
              child: Text(label),
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