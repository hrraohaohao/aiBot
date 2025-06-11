class ModelNameItem {
  final String id;
  final String modelName;

  ModelNameItem({
    required this.id,
    required this.modelName,
  });

  factory ModelNameItem.fromJson(Map<String, dynamic> json) {
    return ModelNameItem(
      id: json['id'] ?? '',
      modelName: json['modelName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelName': modelName,
    };
  }
} 