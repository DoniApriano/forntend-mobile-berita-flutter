// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers, avoid_print, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/model/category_model.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/pages/screen/news_detail_screen.dart';
import 'package:flutter_application_1/pages/screen/user_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewsCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const NewsCategoryScreen(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  _NewsCategoryScreenState createState() => _NewsCategoryScreenState();
}

class _NewsCategoryScreenState extends State<NewsCategoryScreen> {
  List<News> newsData = [];
  CustomColor customColor = CustomColor();

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future fetchAllNewsByCategory() async {
    String? token = await getToken();

    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8000/api/news/${widget.categoryId.toString()}/categoryAll'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        newsData =
            List<News>.from(data['data'].map((json) => News.fromJson(json)));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllNewsByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: customColor.light,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Text(
                  widget.categoryName,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: newsData.length,
                  itemBuilder: (context, index) {
                    final news = newsData[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NewsDetailScreen(news: news),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            "http://10.0.2.2:8000/storage/newsImage/" +
                                                news.image,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserDetailScreen(
                                                            user: news.user),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                news.user.username,
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w500,
                                                  color: customColor.dark,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              news.title,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: customColor.dark,
                                              ),
                                            ),
                                            Text(
                                              news.newsContent,
                                              style: TextStyle(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
