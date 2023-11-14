import 'package:flutter_application_1/model/category_model.dart';
import 'package:flutter_application_1/model/user_model.dart';

class News {
  final int id;
  final String title;
  final String newsContent;
  final String image;
  final Category category;
  final String created;
  final User user;

  News({
    required this.id,
    required this.title,
    required this.newsContent,
    required this.image,
    required this.category,
    required this.created,
    required this.user,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String? ?? "",
      newsContent: json['news_content'] as String? ?? "",
      image: json['image'] as String? ?? "",
      category: Category.fromJson(json['category']),
      created: json['created_at'] as String? ?? "",
      user: User.fromJson(json['user']),
    );
  }
}
