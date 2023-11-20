// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/category_model.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/screen/news_detail_screen.dart';
import 'package:flutter_application_1/screen/search_result_screen.dart';
import 'package:flutter_application_1/screen/search_screen.dart';
import 'package:flutter_application_1/screen/user_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Tab> tabs = [];
  List<News> newsData = [];
  List<News> allNewsData = [];
  Map<int, List<News>> newsDataByCategory = {};
  List<Category> categories = [];
  DateFormat dateFormat = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndTabs();
    fetchAllNews();
  }

  Future<void> fetchCategoriesAndTabs() async {
    await fetchCategories();
    createTabs();
  }

  Future fetchAllNews() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/news'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          allNewsData =
              List<News>.from(data['data'].map((json) => News.fromJson(json)));
        });
      }
    } on Exception catch (e) {
      print("Error == ${e}");
    }
  }

  Future<void> fetchCategories() async {
    try {
      String? token = await getToken();
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/category'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          categories = List<Category>.from(
              data['data'].map((json) => Category.fromJson(json)));
        });
      }
    } on Exception catch (e) {
      print("Error == ${e.toString()}");
    }
  }

  void createTabs() {
    tabs.add(Tab(text: 'Semua Berita'));

    // Add tabs for each category
    tabs.addAll(categories.map((category) {
      int categoryId = category.id;
      fetchNewsByCategory(categoryId);
      return Tab(text: category.name);
    }).toList());
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchNewsByCategory(int categoryId) async {
    try {
      String? token = await getToken();
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/news/$categoryId/categoryAll'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        if (mounted) {
          setState(() {
            newsDataByCategory[categoryId] = List<News>.from(
                data['data'].map((json) => News.fromJson(json)));
          });
        }
      } else {
        throw Exception("Failed to fetch news data");
      }
    } on Exception catch (e) {
      print("Error == ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          backgroundColor: Colors.white,
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
            actions: [
              IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: SearchResult());
                },
                icon: Icon(
                  Icons.search_rounded,
                  color: Colors.black,
                ),
              )
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: tabs,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
            ),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: allNewsData.length,
                itemBuilder: (context, index) {
                  final news = allNewsData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
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
                                color: const Color.fromARGB(255, 207, 207, 207),
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
                                          Text(
                                            news.title,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            news.newsContent,
                                            style: TextStyle(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Column(
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
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                timeago.format(
                                                  DateTime.parse(news.created
                                                      .substring(0, 19)),
                                                  locale:
                                                      'id', // Set the locale to Indonesian
                                                ),
                                                style: TextStyle(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                        SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  );
                },
              ),
              ...categories.map(
                (category) {
                  int categoryId = category.id;
                  List<News>? categoryNews = newsDataByCategory[categoryId];
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: categoryNews?.length ?? 0,
                    itemBuilder: (context, index) {
                      final news = categoryNews![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                news.title,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                news.newsContent,
                                                style: TextStyle(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Column(
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
                                                                  user: news
                                                                      .user),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      news.user.username,
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
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
                                                          .substring(0, 19)),
                                                      locale:
                                                          'id', // Set the locale to Indonesian
                                                    ),
                                                    style: TextStyle(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                            SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
