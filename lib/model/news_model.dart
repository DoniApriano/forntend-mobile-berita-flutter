import 'package:flutter_application_1/model/user_model.dart';

class News {
  final int id;
  final String title;
  final String newsContent;
  final String image;
  final String created;
  final User user;

  News({
    required this.id,
    required this.title,
    required this.newsContent,
    required this.image,
    required this.created,
    required this.user,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String? ?? "",
      newsContent: json['news_content'] as String? ?? "",
      image: json['image'] as String? ?? "",
      created: json['created_at'] as String? ?? "",
      user: User.fromJson(json['user']),
    );
  }
}
