// ignore_for_file: unnecessary_cast

class User {
  final int id;
  final String username;
  final String profilePicture;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? "",
      profilePicture: json['profile_picture'].toString() as String? ?? "",
      email: json['email'] as String? ?? "",
    );
  }
}
