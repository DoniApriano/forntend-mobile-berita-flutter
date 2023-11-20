// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:flutter_application_1/screen/news_detail_screen.dart';
import 'package:flutter_application_1/screen/user_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchResult extends SearchDelegate<String> {
  final List<String> recentSearches = ['Flutter', 'Dart', 'API'];
  List<News> newsData = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.keyboard_arrow_left_rounded,
        color: Colors.black,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Berita'),
                Tab(text: 'Pengguna'),
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder(
                    future: fetchSearchNewsResults(query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        ));
                      } else if (query.isEmpty) {
                        return Center(
                          child: Text("Artikel tidak ditemukan"),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data!.isEmpty) {
                        return Center(
                          child: Text("Artikel tidak ditemukan"),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final news = snapshot.data![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
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
                                            offset:
                                                Offset.fromDirection(-10, 5),
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
                                                        news: news),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        news.title,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                                          user:
                                                                              news.user),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              news.user
                                                                  .username,
                                                              style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    Colors.grey,
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
                                                              locale:
                                                                  'id', // Set the locale to Indonesian
                                                            ),
                                                            style: TextStyle(),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
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
                                    SizedBox(
                                      height: 15,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  FutureBuilder(
                    future: fetchSearchUsersResults(query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        ));
                      } else if (query.isEmpty) {
                        return Center(
                          child: Text("Pengguna tidak ditemukan"),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data!.isEmpty) {
                        return Center(
                          child: Text("Pengguna tidak ditemukan"),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5),
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final user = snapshot.data![index];
                              return Container(
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserDetailScreen(user: user),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          "http://10.0.2.2:8000/storage/userProfilePicture/${user.profilePicture}",
                                        ),
                                      ),
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: Text(user.username),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSearches
        : recentSearches
            .where((suggestion) =>
                suggestion.toLowerCase().startsWith(query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestionList[index]),
            onTap: () {
              query = suggestionList[index];
              showResults(context);
            },
          );
        },
      ),
    );
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List> fetchSearchNewsResults(String query) async {
    String? token = await getToken();
    var headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/search/$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      return List<News>.from(
          data['data']['news'].map((json) => News.fromJson(json)));
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<List> fetchSearchUsersResults(String query) async {
    String? token = await getToken();
    var headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/search/$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      print(data);
      return List<User>.from(
          data['data']['users'].map((json) => User.fromJson(json)));
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
