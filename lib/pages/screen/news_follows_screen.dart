// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/pages/screen/news_detail_screen.dart';
import 'package:flutter_application_1/pages/screen/user_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewsFollowsScreen extends StatefulWidget {
  const NewsFollowsScreen({Key? key}) : super(key: key);

  @override
  _NewsFollowsScreenState createState() => _NewsFollowsScreenState();
}

class _NewsFollowsScreenState extends State<NewsFollowsScreen> {
  List<News> newsData = [];
  CustomColor customColor = CustomColor();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = true;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future fetchNewsByFollows() async {
    try {
      String? token = await getToken();

      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/allNewsByFollowing'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          newsData = List<News>.from(
              data['data'][0].map((json) => News.fromJson(json)));
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      print("Error == ${e.toString()}");
    }
  }

  Future<void> _refresh() async {
    await fetchNewsByFollows();
  }

  @override
  void initState() {
    super.initState();
    fetchNewsByFollows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: Padding(
          padding: EdgeInsets.all(8.0),
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
              }
            },
          ),
        ),
      ),
    );
  }
}
