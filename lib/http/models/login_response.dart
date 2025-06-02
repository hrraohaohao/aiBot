class LoginResponse {
  final String token;
  final int expire;
  final String clientHash;

  LoginResponse({
    required this.token,
    required this.expire,
    required this.clientHash,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      expire: json['expire'] as int,
      clientHash: json['clientHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expire': expire,
      'clientHash': clientHash,
    };
  }
}

// 用户信息模型
class UserInfo {
  final int id;
  final String username;
  final String? nickname;
  final String? avatar;
  final String? email;
  final String? phone;

  UserInfo({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.email,
    this.phone,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'email': email,
      'phone': phone,
    };
  }
} 