// ignore_for_file: unnecessary_cast, unnecessary_this

class User {
  int id;
  String username;
  String profilePicture;
  String email;

  User({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.email,
  });

  set setUsername(String newUsername) {
    this.username = newUsername;
  }

  set setProfilePicture(String newProfilePicture) {
    this.profilePicture = newProfilePicture;
  }

  set setEmail(String newEmail) {
    this.email = newEmail;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? "",
      profilePicture: json['profile_picture'].toString() as String? ?? "",
      email: json['email'] as String? ?? "",
    );
  }
}
