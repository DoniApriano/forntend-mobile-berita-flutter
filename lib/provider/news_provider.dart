import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsProvider extends ChangeNotifier {
  List<News> _news = [];
  List<News> get news => _news;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchNews() async {
    notifyListeners();
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/latestNews'),
      headers: headers,
    );
    var data = json.decode(response.body);
    print(data);
    _news = newsFromJson(data);
    notifyListeners();
  }
}
