// ignore_for_file: prefer_const_constructors, avoid_print, prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/model/comment_model.dart';
import 'package:flutter_application_1/model/news_model.dart'; 
import 'package:flutter_application_1/screen/user_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NewsDetailScreen extends StatefulWidget {
  final News news;

  NewsDetailScreen({required this.news});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool isLoading = true;
  List<Comment> comments = [];
  TextEditingController _commentController = TextEditingController();
  String currentUsername = "";
  DateFormat dateFormat = DateFormat('dd MMMM yyyy');
  CustomColor customColor = CustomColor();

  @override
  void initState() {
    super.initState();
    fetchComments();
    getCurrentUsername();
  }

  Future<void> getCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? "";
    });
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> postReport(int idReported, description, int commentId) async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/josn',
    };

    String type = "comment";

    var requestBody = {
      'reported_user_id': idReported.toString(),
      'comment_id': commentId.toString(),
      'description': description,
    };
    var response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/reportComment'),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data['data']);
    } else {
      print("status code = ${response.statusCode}");
    }
  }

  Future<void> fetchComments() async {
    isLoading = true;
    setState(() {});

    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/news/${widget.news.id}/comment'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        comments = List<Comment>.from(
            data['data'].map((json) => Comment.fromJson(json)));
        isLoading = false;
      });
    } else {
      print(response.statusCode);
    }
  }

  Future<void> sendComment() async {
    String commentText = _commentController.text;
    if (commentText.isNotEmpty) {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };

      var requestBody = {
        'news_id': widget.news.id.toString(),
        'text': commentText,
      };

      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/comment'),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        fetchComments();
        _commentController.clear();
      } else {
        print('Gagal mengirim komentar. Status Code: ${response.body}');
      }
    }
  }

  Future<void> deleteComment(id) async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };

    var response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/comment/${id}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      fetchComments();
    } else {
      print('Gagal menghapus komentar. Status Code: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.news.title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.news.user.username,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              dateFormat.format(DateTime.parse(
                                  widget.news.created.substring(0, 10))),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          width: 410,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(
                                "http://10.0.2.2:8000/storage/newsImage/" +
                                    widget.news.image,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            widget.news.newsContent,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Komentar",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (isLoading)
                          Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (comments.isEmpty)
                          Center(
                            child: Text(
                              "Tidak ada komentar untuk postingan ini",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final isCurrentUserComment =
                                  comment.user.username == currentUsername;
                              final id = comment.id;

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
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
                                  child: ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserDetailScreen(
                                                    user: comment.user),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          "http://10.0.2.2:8000/storage/userProfilePicture/${comment.user.profilePicture}",
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      comment.text,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(comment.user.username),
                                    onLongPress: () {
                                      if (isCurrentUserComment) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Hapus Komentar"),
                                              content: Text(
                                                  "Apakah anda ingin menghapus komentar?"),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text("Batal"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("Hapus"),
                                                  onPressed: () {
                                                    deleteComment(id);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Pesan"),
                                              content: Text(
                                                  "Anda menekan lama komentar yang berbeda."),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text("Report"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Report Komentar ${comment.user.id}"),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              ListTile(
                                                                title: Text(
                                                                    "Spam"),
                                                                onTap: () {
                                                                  postReport(
                                                                      comment
                                                                          .user
                                                                          .id,
                                                                      "Spam",
                                                                      comment
                                                                          .id);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              ListTile(
                                                                title: Text(
                                                                    "Abuse"),
                                                                onTap: () {
                                                                  postReport(
                                                                      comment
                                                                          .user
                                                                          .id,
                                                                      "Abuse",
                                                                      comment
                                                                          .id);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Tutup AlertDialog kedua
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Ketik komentar Anda...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    contentPadding: EdgeInsets.all(10.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Implementasi pengiriman komentar ke API
                                    sendComment();
                                  },
                                  style: ButtonStyle(),
                                  icon: Icon(Icons.send),
                                  label: Text(''),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
