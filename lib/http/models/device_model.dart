class DeviceModel {
  final String id;
  final int userId;
  final String macAddress;
  final String lastConnectedAt;
  final int autoUpdate;
  final String board;
  final String alias;
  final String agentId;
  final String appVersion;
  final int sort;
  final int updater;
  final String updateDate;
  final int creator;
  final String createDate;

  DeviceModel({
    required this.id,
    required this.userId,
    required this.macAddress,
    required this.lastConnectedAt,
    required this.autoUpdate,
    required this.board,
    required this.alias,
    required this.agentId,
    required this.appVersion,
    required this.sort,
    required this.updater,
    required this.updateDate,
    required this.creator,
    required this.createDate,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? 0,
      macAddress: json['macAddress'] ?? '',
      lastConnectedAt: json['lastConnectedAt'] ?? '',
      autoUpdate: json['autoUpdate'] ?? 0,
      board: json['board'] ?? '',
      alias: json['alias'] ?? '',
      agentId: json['agentId'] ?? '',
      appVersion: json['appVersion'] ?? '',
      sort: json['sort'] ?? 0,
      updater: json['updater'] ?? 0,
      updateDate: json['updateDate'] ?? '',
      creator: json['creator'] ?? 0,
      createDate: json['createDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'macAddress': macAddress,
      'lastConnectedAt': lastConnectedAt,
      'autoUpdate': autoUpdate,
      'board': board,
      'alias': alias,
      'agentId': agentId,
      'appVersion': appVersion,
      'sort': sort,
      'updater': updater,
      'updateDate': updateDate,
      'creator': creator,
      'createDate': createDate,
    };
  }
} 