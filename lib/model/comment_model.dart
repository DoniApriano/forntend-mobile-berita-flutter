import 'package:flutter_application_1/model/user_model.dart';

class Comment {
  final int id;
  final String text;
  final User user;

  Comment({
    required this.id,
    required this.text,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'],
      user: User.fromJson(json['user']),
    );
  }
}
