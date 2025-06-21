class ChatDeviceHistoryItem {
  final int id;
  final String createdAt;
  final String chatType;
  final String content;
  final String audioId;
  final String macAddress;
  final String riskKeywords;
  final String sessionId;

  ChatDeviceHistoryItem({
    required this.id,
    required this.createdAt,
    required this.chatType,
    required this.content,
    required this.audioId,
    required this.macAddress,
    required this.riskKeywords,
    required this.sessionId,
  });

  factory ChatDeviceHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatDeviceHistoryItem(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      chatType: json['chatType']?.toString() ?? '',
      content: json['content'] ?? '',
      audioId: json['audioId'] ?? '',
      macAddress: json['macAddress'] ?? '',
      riskKeywords: json['riskKeywords'] ?? '',
      sessionId: json['sessionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'chatType': chatType,
      'content': content,
      'audioId': audioId,
      'macAddress': macAddress,
      'riskKeywords': riskKeywords,
      'sessionId': sessionId,
    };
  }
} 