import 'dart:convert';

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  int id;
  String name;
  String email;
  String phone;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
  };

  User copy() => User(
      id: id,
      name: name,
      email: email,
      phone: phone,
  );
}