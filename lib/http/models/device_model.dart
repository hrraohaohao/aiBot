class DeviceModel {
  final String id;
  final String userId;
  final String macAddress;
  final String lastConnectedAt;
  final int autoUpdate;
  final String board;
  final String alias;
  final String agentId;
  final String appVersion;
  final int sort;
  final dynamic updater;
  final String updateDate;
  final String creator;
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
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      macAddress: json['macAddress']?.toString() ?? '',
      lastConnectedAt: json['lastConnectedAt']?.toString() ?? '',
      autoUpdate: json['autoUpdate'] is int ? json['autoUpdate'] : 0,
      board: json['board']?.toString() ?? '',
      alias: json['alias']?.toString() ?? '',
      agentId: json['agentId']?.toString() ?? '',
      appVersion: json['appVersion']?.toString() ?? '',
      sort: json['sort'] is int ? json['sort'] : 0,
      updater: json['updater'],
      updateDate: json['updateDate']?.toString() ?? '',
      creator: json['creator']?.toString() ?? '',
      createDate: json['createDate']?.toString() ?? '',
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