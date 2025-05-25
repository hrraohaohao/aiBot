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