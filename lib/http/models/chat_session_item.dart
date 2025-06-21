class ChatSessionItem {
  final String createdAt;
  final String chatType;
  final String content;
  final String audioId;
  final String macAddress;

  ChatSessionItem({
    required this.createdAt,
    required this.chatType,
    required this.content,
    required this.audioId,
    required this.macAddress,
  });

  factory ChatSessionItem.fromJson(Map<String, dynamic> json) {
    return ChatSessionItem(
      createdAt: json['createdAt'] ?? '',
      chatType: json['chatType'] ?? '',
      content: json['content'] ?? '',
      audioId: json['audioId'] ?? '',
      macAddress: json['macAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'chatType': chatType,
      'content': content,
      'audioId': audioId,
      'macAddress': macAddress,
    };
  }
} 