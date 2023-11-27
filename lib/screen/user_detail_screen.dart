// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, prefer_interpolation_to_compose_strings, avoid_init_to_null, unnecessary_getters_setters, unnecessary_brace_in_string_interps, avoid_return_types_on_setters, unnecessary_this, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom/custom.dart';
import 'package:flutter_application_1/model/news_model.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:flutter_application_1/screen/news_detail_screen.dart';
import 'package:flutter_application_1/screen/news_update_screen.dart';
import 'package:flutter_application_1/screen/profile_screen.dart';
import 'package:flutter_application_1/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class UserDetailScreen extends StatefulWidget {
  final User user;

  UserDetailScreen({required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  var countFollowers = 0;
  var countFollowing = 0;
  var isFollowing = false;
  String currentEmail = "";
  bool isButtonVisible = true;
  List<News> newsData = [];
  Custom _custom = Custom();

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getCurrentEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentEmail = prefs.getString('email') ?? "";
    });
    if (widget.user.email == currentEmail) {
      setState(() {
        isButtonVisible = false;
      });
    }
  }

  Future<void> deleteNews(var id) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Anda yakin ingin menghapus berita ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/news/${id.toString()}'),
        headers: headers,
      );

      var data = json.decode(response.body.toString());

      if (response.statusCode == 200) {
        _custom.showAlertDialog(context, "Berhasil", "Menghapus berita");
        await fetchNewsByUserId();
      } else {
        print(data);
        print(response.statusCode);
      }
    }
  }

  Future<void> unFollow(int idUser) async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/unFollow/${idUser.toString()}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        isFollowing = false;
        countFollowers -= 1;
      });
    }
  }

  Future<void> follow(int idUserFollow) async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var requestBody = {
      'following': idUserFollow.toString(),
    };
    var response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/follow'),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        isFollowing = true;
        countFollowers += 1;
      });
    }
  }

  Future<void> checkIfFollowing() async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/checkIfFollowing/${widget.user.id}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      bool followingStatus = data['status'];
      setState(() {
        isFollowing = followingStatus;
      });
    }
  }

  Future<void> fetchUserFollowers() async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/showFollowers/${widget.user.id}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        countFollowers = data['data']['count'];
      });
      // for (var i = 0; i < data['data']['followers'].length; i++) {
      //   print(data['data']['followers'][i]['followers']['username']);
      // }
    } else {
      print("status code = ${response.statusCode}");
    }
  }

  Future<void> fetchUserFollowing() async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/showFollowing/${widget.user.id}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        countFollowing = data['data']['count'];
      });
    } else {
      print("status code = ${response.statusCode}");
    }
  }

  Future<void> fetchNewsByUserId() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/news/${widget.user.id}/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body.toString());
        setState(() {
          newsData =
              List<News>.from(data['data'].map((json) => News.fromJson(json)));
        });
      } else {
        print("status code = ${response.statusCode}");
      }
    } on Exception catch (e) {
      print("error == ${e.toString()}");
    }
  }

  Future<void> _refresh() async {
    await fetchNewsByUserId();
    await fetchUserFollowers();
    await checkIfFollowing();
    await fetchUserFollowing();
  }

  @override
  void initState() {
    super.initState();
    Future.wait([
      getCurrentEmail(),
      fetchUserFollowing(),
      fetchUserFollowers(),
      checkIfFollowing(),
      fetchNewsByUserId(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "http://10.0.2.2:8000/storage/userProfilePicture/" +
                        widget.user.profilePicture,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Container(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            image: DecorationImage(
                              image: NetworkImage(
                                  "http://10.0.2.2:8000/storage/userProfilePicture/" +
                                      widget.user.profilePicture),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.user.username,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                  offset: Offset.fromDirection(-10, 5),
                                  color:
                                      const Color.fromARGB(255, 207, 207, 207),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Mengikuti",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  countFollowing.toString(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                  offset: Offset.fromDirection(-10, 5),
                                  color:
                                      const Color.fromARGB(255, 207, 207, 207),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {},
                              child: Column(
                                children: [
                                  Text(
                                    "Pengikut",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    countFollowers.toString(),
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Visibility(
                          visible: isButtonVisible,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isFollowing) {
                                unFollow(widget.user.id);
                              } else {
                                follow(widget.user.id);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                isFollowing ? Colors.grey : Colors.blue,
                              ),
                            ),
                            child: Text(
                              isFollowing ? "Berhenti Mengikuti" : "Ikuti",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: newsData.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final news = newsData[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
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
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                                  builder:
                                                                      (context) =>
                                                                          UserDetailScreen(
                                                                    user: news
                                                                        .user,
                                                                  ),
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
                                                              locale: 'id',
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
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: PopupMenuButton(
                                        itemBuilder: (BuildContext context) {
                                          if (news.user.email == currentEmail) {
                                            return [
                                              PopupMenuItem(
                                                value: 'option1',
                                                child: Text('Hapus'),
                                                onTap: () {
                                                  deleteNews(news.id);
                                                },
                                              ),
                                              PopupMenuItem(
                                                value: 'option2',
                                                child: Text('Ubah'),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          NewsUpdateScreen(
                                                              news: news),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ];
                                          } else {
                                            return [
                                              PopupMenuItem(
                                                value: 'otherOption',
                                                child: Text('Tandai'),
                                              ),
                                            ];
                                          }
                                        },
                                        onSelected: (value) {
                                          if (value == 'option1') {
                                            // Handle action for Option 1
                                          } else if (value == 'option2') {
                                            // Handle action for Option 2
                                          } else if (value == 'option3') {
                                            // Handle action for Option 3
                                          } else if (value == 'otherOption') {
                                            // Handle action for the option for others
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
