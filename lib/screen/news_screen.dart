// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/screen/news_detail_screen.dart';
import 'package:flutter_application_1/screen/user_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/model/category_model.dart' as category;
import 'package:timeago/timeago.dart' as timeago;

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> newsData = [];
  Set<int> bookmarkedNewsIds = Set<int>();
  List<News> newsFollowsData = [];
  bool isLoading = true;
  CustomColor customColor = CustomColor();
  FocusNode focusNode = FocusNode();
  late var timer;
  String currentEmail = "";

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getCurrentEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentEmail = prefs.getString('email') ?? "";
    });
  }

  Future postBookmark(int newsId) async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var requestBody = {
        'news_id': newsId.toString(),
      };

      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/bookmarks'),
        headers: headers,
        body: requestBody,
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
      }
    } on Exception catch (e) {
      print("Error == ${e}");
    }
  }

  Future<void> fetchBookmarkedNewsIds() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/bookmarks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          bookmarkedNewsIds =
              Set<int>.from(data['data'].map((item) => item['news_id']));
        });
      }
    } on Exception catch (e) {
      print("Error fetching bookmarked news IDs == $e");
    }
  }

  Future unbookmarkNews(int newsId) async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/bookmarks/${newsId}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        bookmarkedNewsIds.remove(newsId);
      }
    } on Exception catch (e) {
      print("Error unbookmarking news == $e");
    }
  }

  Future fetchNews() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/latestNews'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          newsData = List<News>.from(
              data['data']['data'].map((json) => News.fromJson(json)));
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      print("Error == ${e}");
    }
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
          newsFollowsData =
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
    fetchNews();
    fetchNewsByFollows();
    getCurrentEmail();
    fetchBookmarkedNewsIds();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Pawarta",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      bottom: 20,
                    ),
                    child: Text(
                      "Berita Terbaru",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 450.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                    ),
                    items: newsData.map(
                      (news) {
                        return Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsDetailScreen(news: news),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "http://10.0.2.2:8000/storage/newsImage/" +
                                          news.image,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        bottom: 10.0,
                                        left: 10.0,
                                        child: Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  news.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
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
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        news.user.username,
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      bottom: 20,
                    ),
                    child: Text(
                      "Untuk Anda",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: newsFollowsData.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final news = newsFollowsData[index];
                      bool isBookmarked = bookmarkedNewsIds.contains(news.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
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
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 200,
                                            height: 120,
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
                                          Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    news.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    news.newsContent,
                                                    style: TextStyle(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UserDetailScreen(
                                                                user: news.user,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          news.user.username,
                                                          style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        timeago.format(
                                                          DateTime.parse(news
                                                              .created
                                                              .substring(
                                                                  0, 19)),
                                                          locale: 'id',
                                                        ),
                                                        style: TextStyle(),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
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
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: PopupMenuButton(
                                    itemBuilder: (BuildContext context) {
                                      if (news.user.email == currentEmail) {
                                        return [
                                          PopupMenuItem(
                                            value: 'option1',
                                            child: Text('Option 1'),
                                          ),
                                          PopupMenuItem(
                                            value: 'option2',
                                            child: Text('Option 2'),
                                          ),
                                          PopupMenuItem(
                                            value: 'option3',
                                            child: Text('Option 3'),
                                          ),
                                        ];
                                      } else {
                                        return [
                                          PopupMenuItem(
                                            value: 'tandai',
                                            child: Text(isBookmarked
                                                ? "Batal tandai"
                                                : "Tandai"),
                                            onTap: () {
                                              if (isBookmarked) {
                                                unbookmarkNews(news.id);
                                                setState(() {
                                                  bookmarkedNewsIds
                                                      .remove(news.id);
                                                });
                                              } else {
                                                postBookmark(news.id);
                                                setState(() {
                                                  bookmarkedNewsIds
                                                      .add(news.id);
                                                });
                                              }
                                            },
                                          ),
                                        ];
                                      }
                                    },
                                    icon: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
