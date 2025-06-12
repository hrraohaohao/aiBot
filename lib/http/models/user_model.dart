class UserModel {
  final String id;
  final String username;
  final int superAdmin;
  final String token;
  final int status;

  UserModel({
    required this.id,
    required this.username,
    required this.superAdmin,
    required this.token,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      superAdmin: json['superAdmin'] ?? 0,
      token: json['token'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'superAdmin': superAdmin,
      'token': token,
      'status': status,
    };
  }
  
  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, superAdmin: $superAdmin, token: $token, status: $status}';
  }
} 