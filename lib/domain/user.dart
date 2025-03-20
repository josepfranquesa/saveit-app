import 'dart:convert';

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.emailVerifiedAt,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  int id;
  String name;
  String email;
  String? phone;
  String? password;
  DateTime? emailVerifiedAt;
  String? rememberToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    emailVerifiedAt: json["email_verified_at"] != null ? DateTime.parse(json["email_verified_at"]) : null,
    rememberToken: json["remember_token"],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    deletedAt: json["deleted_at"] != null ? DateTime.parse(json["deleted_at"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "password": password,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "remember_token": rememberToken,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt?.toIso8601String(),
  };

  User copy() => User(
    id: id,
    name: name,
    email: email,
    phone: phone,
    password: password,
    emailVerifiedAt: emailVerifiedAt,
    rememberToken: rememberToken,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
