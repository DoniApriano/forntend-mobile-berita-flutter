import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/model/user_model.dart';

class Bookmark {
  final int id;
  final News news;
  final User user;

  Bookmark({required this.id, required this.news, required this.user});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as int,
      news: News.fromJson(json['news']),
      user: User.fromJson(json['user']),
    );
  }
}
