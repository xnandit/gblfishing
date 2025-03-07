class UserModel {
  final String id;
  final String name;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }
}
