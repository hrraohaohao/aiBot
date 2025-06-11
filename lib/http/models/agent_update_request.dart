class AgentUpdateRequest {
  final String agentCode;
  final String agentName;
  final String asrModelId;
  final String vadModelId;
  final String llmModelId;
  final String vllmModelId;
  final String ttsModelId;
  final String ttsVoiceId;
  final String memModelId;
  final String intentModelId;
  final String systemPrompt;
  final String summaryMemory;
  final int chatHistoryConf;
  final String langCode;
  final String language;
  final int sort;

  AgentUpdateRequest({
    required this.agentName,
    this.agentCode = '',
    this.asrModelId = '',
    this.vadModelId = '',
    this.llmModelId = '',
    this.vllmModelId = '',
    this.ttsModelId = '',
    this.ttsVoiceId = '',
    this.memModelId = '',
    this.intentModelId = '',
    this.systemPrompt = '',
    this.summaryMemory = '',
    this.chatHistoryConf = 0,
    this.langCode = 'zh_CN',
    this.language = '中文',
    this.sort = 0,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'agentName': agentName,
    };
    
    // 只添加非空字段
    if (agentCode.isNotEmpty) data['agentCode'] = agentCode;
    if (asrModelId.isNotEmpty) data['asrModelId'] = asrModelId;
    if (vadModelId.isNotEmpty) data['vadModelId'] = vadModelId;
    if (llmModelId.isNotEmpty) data['llmModelId'] = llmModelId;
    if (vllmModelId.isNotEmpty) data['vllmModelId'] = vllmModelId;
    if (ttsModelId.isNotEmpty) data['ttsModelId'] = ttsModelId;
    if (ttsVoiceId.isNotEmpty) data['ttsVoiceId'] = ttsVoiceId;
    if (memModelId.isNotEmpty) data['memModelId'] = memModelId;
    if (intentModelId.isNotEmpty) data['intentModelId'] = intentModelId;
    if (systemPrompt.isNotEmpty) data['systemPrompt'] = systemPrompt;
    if (summaryMemory.isNotEmpty) data['summaryMemory'] = summaryMemory;
    
    // 添加其他字段
    data['chatHistoryConf'] = chatHistoryConf;
    data['langCode'] = langCode;
    data['language'] = language;
    data['sort'] = sort;
    
    return data;
  }
} 