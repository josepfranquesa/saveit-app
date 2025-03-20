import 'dart:convert';

import 'package:SaveIt/domain/user.dart';

class LoginResponse {

  LoginResponse({required this.access_token, required this.token_type, required this.expires_in, required this.user});

  String access_token;
  String token_type;
  int expires_in;
  User user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse.fromMap(json);

  String toJson() => json.encode(toMap());

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
    access_token: json["access_token"],
    token_type: json["token_type"],
    expires_in: json["expires_in"],
    user: User.fromMap(json["user"]),
  );

  Map<String, dynamic> toMap() => {
    "access_token": access_token,
    "token_type": token_type,
    "expires_in": expires_in,
    "user": user.toMap(),
  };

  LoginResponse copy() => LoginResponse(
    access_token: access_token,
    token_type: token_type,
    expires_in: expires_in,
    user: user,
  );

}