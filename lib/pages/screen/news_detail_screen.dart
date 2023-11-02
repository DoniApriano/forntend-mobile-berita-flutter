// ignore_for_file: prefer_const_constructors, avoid_print, prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/comment_model.dart';
import 'package:flutter_application_1/model/news_model.dart'; // Pastikan import model News yang sesuai
import 'package:flutter_application_1/pages/screen/user_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    fetchComments();
    print("news ${widget.news.title}");
    getCurrentUsername();
  }

  Future<void> getCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? "";
      print(currentUsername);
    });
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> postReport(int idReported, descriprion) async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/josn',
    };

    String type = "comment";

    var requestBody = {
      'reported_user_id': idReported.toString(),
      'type': type,
      'description': descriprion,
    };
    var response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/report'),
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
      print(data['data']);
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "http://10.0.2.2:8000/storage/newsImage/${widget.news.image}",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailScreen(user: widget.news.user),
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
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image: NetworkImage(
                                  "http://10.0.2.2:8000/storage/userProfilePicture/" +
                                      widget.news.user.profilePicture,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10), // Spasi antara gambar dan teks
                          Text(
                            widget.news.user.username,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          widget.news.title,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.news.newsContent,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Comments",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (comments.isEmpty)
              Center(
                child: Text("Comment is empty"),
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

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        "http://10.0.2.2:8000/storage/userProfilePicture/${comment.user.profilePicture}",
                        width: 40,
                        height: 40,
                      ),
                    ),
                    title: Text(comment.text),
                    subtitle: Text(comment.user.username),
                    onLongPress: () {
                      if (isCurrentUserComment) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Hapus Komentar"),
                              content:
                                  Text("Apakah anda ingin menghapus komentar?"),
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
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                title: Text("Spam"),
                                                onTap: () {
                                                  postReport(
                                                      comment.user.id, "Spam");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              ListTile(
                                                title: Text("Abuse"),
                                                onTap: () {
                                                  postReport(
                                                      comment.user.id, "Abuse");
                                                  Navigator.of(context)
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
    );
  }
}