class ChatDeviceHistoryItem {
  final String id;
  final String createdAt;
  final dynamic chatType;
  final String content;
  final String? audioId;
  final String macAddress;
  final String? riskKeywords;
  final String sessionId;

  ChatDeviceHistoryItem({
    required this.id,
    required this.createdAt,
    required this.chatType,
    required this.content,
    this.audioId,
    required this.macAddress,
    this.riskKeywords,
    required this.sessionId,
  });

  factory ChatDeviceHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatDeviceHistoryItem(
      id: json['id']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      chatType: json['chatType'],
      content: json['content']?.toString() ?? '',
      audioId: json['audioId']?.toString(),
      macAddress: json['macAddress']?.toString() ?? '',
      riskKeywords: json['riskKeywords']?.toString(),
      sessionId: json['sessionId']?.toString() ?? '',
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

  String getChatTypeString() {
    if (chatType == 1 || chatType.toString() == "1") {
      return "1";
    } else if (chatType == 2 || chatType.toString() == "2") {
      return "2";
    }
    return chatType?.toString() ?? "";
  }
} 