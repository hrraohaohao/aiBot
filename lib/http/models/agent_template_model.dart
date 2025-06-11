class AgentTemplateModel {
  final String id;
  final String agentCode;
  final String agentName;
  final String asrModelId;
  final String vadModelId;
  final String llmModelId;
  final String vllmModelId;
  final String ttsModelId;
  final String? ttsVoiceId;
  final String memModelId;
  final String intentModelId;
  final int chatHistoryConf;
  final String systemPrompt;
  final String? summaryMemory;
  final String langCode;
  final String language;
  final int sort;
  final String? creator;
  final String? createdAt;
  final String? updater;
  final String? updatedAt;

  AgentTemplateModel({
    required this.id,
    required this.agentCode,
    required this.agentName,
    required this.asrModelId,
    required this.vadModelId,
    required this.llmModelId,
    required this.vllmModelId,
    required this.ttsModelId,
    this.ttsVoiceId,
    required this.memModelId,
    required this.intentModelId,
    required this.chatHistoryConf,
    required this.systemPrompt,
    this.summaryMemory,
    required this.langCode,
    required this.language,
    required this.sort,
    this.creator,
    this.createdAt,
    this.updater,
    this.updatedAt,
  });

  factory AgentTemplateModel.fromJson(Map<String, dynamic> json) {
    return AgentTemplateModel(
      id: json['id'] as String,
      agentCode: json['agentCode'] as String,
      agentName: json['agentName'] as String,
      asrModelId: json['asrModelId'] as String,
      vadModelId: json['vadModelId'] as String,
      llmModelId: json['llmModelId'] as String,
      vllmModelId: json['vllmModelId'] as String,
      ttsModelId: json['ttsModelId'] as String,
      ttsVoiceId: json['ttsVoiceId'] as String?,
      memModelId: json['memModelId'] as String,
      intentModelId: json['intentModelId'] as String,
      chatHistoryConf: json['chatHistoryConf'] as int,
      systemPrompt: json['systemPrompt'] as String,
      summaryMemory: json['summaryMemory'] as String?,
      langCode: json['langCode'] as String,
      language: json['language'] as String,
      sort: json['sort'] as int,
      creator: json['creator'] as String?,
      createdAt: json['createdAt'] as String?,
      updater: json['updater'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentCode': agentCode,
      'agentName': agentName,
      'asrModelId': asrModelId,
      'vadModelId': vadModelId,
      'llmModelId': llmModelId,
      'vllmModelId': vllmModelId,
      'ttsModelId': ttsModelId,
      'ttsVoiceId': ttsVoiceId,
      'memModelId': memModelId,
      'intentModelId': intentModelId,
      'chatHistoryConf': chatHistoryConf,
      'systemPrompt': systemPrompt,
      'summaryMemory': summaryMemory,
      'langCode': langCode,
      'language': language,
      'sort': sort,
      'creator': creator,
      'createdAt': createdAt,
      'updater': updater,
      'updatedAt': updatedAt,
    };
  }
} 