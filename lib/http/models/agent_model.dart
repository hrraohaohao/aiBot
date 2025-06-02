class AgentModel {
  final String id;
  final String agentName;
  final String ttsModelName;
  final String ttsVoiceName;
  final String llmModelName;
  final String vllmModelName;
  final String memModelId;
  final String systemPrompt;
  final String summaryMemory;
  final String lastConnectedAt;
  final int deviceCount;

  AgentModel({
    required this.id,
    required this.agentName,
    required this.ttsModelName,
    required this.ttsVoiceName,
    required this.llmModelName,
    required this.vllmModelName,
    required this.memModelId,
    required this.systemPrompt,
    required this.summaryMemory,
    required this.lastConnectedAt,
    required this.deviceCount,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] ?? '',
      agentName: json['agentName'] ?? '',
      ttsModelName: json['ttsModelName'] ?? '',
      ttsVoiceName: json['ttsVoiceName'] ?? '',
      llmModelName: json['llmModelName'] ?? '',
      vllmModelName: json['vllmModelName'] ?? '',
      memModelId: json['memModelId'] ?? '',
      systemPrompt: json['systemPrompt'] ?? '',
      summaryMemory: json['summaryMemory'] ?? '',
      lastConnectedAt: json['lastConnectedAt'] ?? '',
      deviceCount: json['deviceCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentName': agentName,
      'ttsModelName': ttsModelName,
      'ttsVoiceName': ttsVoiceName,
      'llmModelName': llmModelName,
      'vllmModelName': vllmModelName,
      'memModelId': memModelId,
      'systemPrompt': systemPrompt,
      'summaryMemory': summaryMemory,
      'lastConnectedAt': lastConnectedAt,
      'deviceCount': deviceCount,
    };
  }
} 