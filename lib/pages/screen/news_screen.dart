// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/pages/screen/news_category_screen.dart';
import 'package:flutter_application_1/pages/screen/news_detail_screen.dart';
import 'package:flutter_application_1/pages/screen/user_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/model/category_model.dart' as category;

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> newsData = [];
  Map<int, List<News>> newsDataByCategory = {};
  TextEditingController _textSearchController = TextEditingController();
  List<category.Category> categories = [];
  bool isLoading = true;
  CustomColor customColor = CustomColor();
  FocusNode focusNode = FocusNode();
  late var timer;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

  Future fetchNewsByCategory(int id) async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/news/$id/categoryPaginate'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        if (mounted) {
          setState(() {
            newsDataByCategory[id] = List<News>.from(
                data['data']['data'].map((json) => News.fromJson(json)));
            isLoading = false;
          });
        }
      } else {
        print("hai ${response.body}");
        throw Exception("Failed to fetch news data");
      }
    } on Exception catch (e) {
      print("Error == ${e.toString()}");
    }
  }

  Future fetchCategory() async {
    try {
      String? token = await getToken();

      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/category'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          categories = List<category.Category>.from(
              data['data'].map((json) => category.Category.fromJson(json)));
        });
      }
    } on Exception catch (e) {
      print("Error == ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory().then((_) {
      for (var category in categories) {
        fetchNewsByCategory(category.id);
      }
    });
    fetchNews();
  }

  @override
  void dispose() {
    _textSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 249, 1),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 15,
                  left: 15,
                  bottom: 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2,
                        offset: Offset.zero,
                        color: const Color.fromARGB(255, 207, 207, 207),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    cursorHeight: 20,
                    controller: _textSearchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      label: Text("Cari Berita ..."),
                      labelStyle: TextStyle(
                        color: customColor.purple,
                      ),
                      prefixIconColor: customColor.purple,
                      prefixIcon: Icon(Icons.search),
                      suffixIconColor: customColor.purple,
                      suffixIcon: Icon(Icons.send_sharp),
                    ),
                  ),
                ),
              ),
              buildNewsColumn(newsData, _textSearchController),
              buildCategoryList(categories),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNewsColumn(
      List<News> newsData, TextEditingController textSearchController) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    return Column(children: [
      Center(
          child: Column(
        children: [
          SizedBox(
            height: 30,
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
                            builder: (context) => NewsDetailScreen(news: news),
                          ),
                        );
                      },
                      child: Container(
                        width: 370,
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
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 10.0,
                              left: 10.0,
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
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
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        news.title,
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: customColor.dark,
                                          fontWeight: FontWeight.w500,
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
                    );
                  },
                );
              },
            ).toList(),
          ),
        ],
      ))
    ]);
  }

  Widget buildCategoryList(List<category.Category> categories) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: customColor.dark,
                            ),
                          ),
                        ),
                      ),
                      buildNewsByCategoryListView(category.id),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsCategoryScreen(
                                  categoryId: category.id,
                                  categoryName: category.name),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: customColor.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Lihat Semua",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildNewsByCategoryListView(int categoryId) {
    List<News> newsByCategory = newsDataByCategory[categoryId] ?? [];

    if (isLoading) {
      return CircularProgressIndicator();
    } else {
      if (newsDataByCategory.isNotEmpty) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: newsByCategory.length,
          itemBuilder: (context, index) {
            final news = newsByCategory[index];
            return Column(
              children: [
                Container(
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
                            builder: (context) => NewsDetailScreen(news: news),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserDetailScreen(user: news.user),
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
                SizedBox(
                  height: 15,
                )
              ],
            );
          },
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Belum Ada Berita",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      }
    }
  }
}
