class AgentDetailModel {
  final String id;
  final String userId;
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
  final int chatHistoryConf;
  final String systemPrompt;
  final String summaryMemory;
  final String langCode;
  final String language;
  final int sort;
  final String creator;
  final String createdAt;
  final String updater;
  final String updatedAt;

  AgentDetailModel({
    required this.id,
    required this.userId,
    required this.agentCode,
    required this.agentName,
    required this.asrModelId,
    required this.vadModelId,
    required this.llmModelId,
    required this.vllmModelId,
    required this.ttsModelId,
    required this.ttsVoiceId,
    required this.memModelId,
    required this.intentModelId,
    required this.chatHistoryConf,
    required this.systemPrompt,
    required this.summaryMemory,
    required this.langCode,
    required this.language,
    required this.sort,
    required this.creator,
    required this.createdAt,
    required this.updater,
    required this.updatedAt,
  });

  factory AgentDetailModel.fromJson(Map<String, dynamic> json) {
    return AgentDetailModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      agentCode: json['agentCode'] ?? '',
      agentName: json['agentName'] ?? '',
      asrModelId: json['asrModelId'] ?? '',
      vadModelId: json['vadModelId'] ?? '',
      llmModelId: json['llmModelId'] ?? '',
      vllmModelId: json['vllmModelId'] ?? '',
      ttsModelId: json['ttsModelId'] ?? '',
      ttsVoiceId: json['ttsVoiceId'] ?? '',
      memModelId: json['memModelId'] ?? '',
      intentModelId: json['intentModelId'] ?? '',
      chatHistoryConf: json['chatHistoryConf'] ?? 0,
      systemPrompt: json['systemPrompt'] ?? '',
      summaryMemory: json['summaryMemory'] ?? '',
      langCode: json['langCode'] ?? '',
      language: json['language'] ?? '',
      sort: json['sort'] ?? 0,
      creator: json['creator'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updater: json['updater'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
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