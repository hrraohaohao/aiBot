class ModelVoiceItem {
  final String id;
  final String name;

  ModelVoiceItem({
    required this.id,
    required this.name,
  });

  factory ModelVoiceItem.fromJson(Map<String, dynamic> json) {
    return ModelVoiceItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
} 