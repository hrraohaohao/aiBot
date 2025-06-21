class AgentSessionItem {
  final String sessionId;
  final String createdAt;
  final int chatCount;

  AgentSessionItem({
    required this.sessionId,
    required this.createdAt,
    required this.chatCount,
  });

  factory AgentSessionItem.fromJson(Map<String, dynamic> json) {
    return AgentSessionItem(
      sessionId: json['sessionId'] as String,
      createdAt: json['createdAt'] as String,
      chatCount: json['chatCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'createdAt': createdAt,
      'chatCount': chatCount,
    };
  }
} 