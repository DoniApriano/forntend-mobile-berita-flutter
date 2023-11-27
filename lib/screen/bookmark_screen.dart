// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/bookmark_model.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/screen/news_detail_screen.dart';
import 'package:flutter_application_1/screen/user_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Bookmark> bookmarkData = [];
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

  Future<void> fetchBookmarkedNews() async {
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
          bookmarkData = List<Bookmark>.from(
              data["data"].map((json) => Bookmark.fromJson(json)));
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
        await fetchBookmarkedNews();
      }
    } on Exception catch (e) {
      print("Error unbookmarking news == $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookmarkedNews();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Artikel",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: bookmarkData.isEmpty
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Belum ada Artikel yang ditandai",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookmarkData.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final bookmark = bookmarkData[index];
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
                                              NewsDetailScreen(
                                                  news: bookmark.news),
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
                                                    bookmark.news.image,
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
                                                  bookmark.news.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  bookmark.news.newsContent,
                                                  style: TextStyle(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                              user: bookmark
                                                                  .news.user,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        bookmark
                                                            .news.user.username,
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
                                                        DateTime.parse(bookmark
                                                            .news.created
                                                            .substring(0, 19)),
                                                        locale: 'id',
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
                              Positioned(
                                top: 5,
                                right: 5,
                                child: PopupMenuButton(
                                  itemBuilder: (BuildContext context) {
                                    if (bookmark.news.user.email ==
                                        currentEmail) {
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
                                          child: Text("Hapus tandai"),
                                          onTap: () {
                                            unbookmarkNews(bookmark.news.id);
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
        ),
      ),
    );
  }
}
