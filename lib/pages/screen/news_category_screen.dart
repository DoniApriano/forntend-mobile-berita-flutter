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
  bool isLoading = true;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future fetchAllNewsByCategory() async {
    try {
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
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      print("Error == ${e.toString()}");
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
                padding: const EdgeInsets.only(top: 30, left: 8, right: 8),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        spreadRadius: 2,
                        offset: Offset.fromDirection(-10, 5),
                        color: const Color.fromARGB(255, 207, 207, 207),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.categoryName,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: customColor.dark,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: newsData.length,
                  itemBuilder: (context, index) {
                    final news = newsData[index];
                    if (isLoading) {
                      return CircularProgressIndicator();
                    } else {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3,
                                    spreadRadius: 2,
                                    offset: Offset.fromDirection(-10, 5),
                                    color: const Color.fromARGB(
                                        255, 207, 207, 207),
                                  ),
                                ],
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
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 410,
                                            height: 260,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  "http://10.0.2.2:8000/storage/newsImage/" +
                                                      news.image,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  news.title,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: customColor.dark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    "http://10.0.2.2:8000/storage/userProfilePicture/" +
                                                        news.user
                                                            .profilePicture,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              news.user.username,
                                              style: TextStyle(
                                                color: customColor.dark,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
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
                    }
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
