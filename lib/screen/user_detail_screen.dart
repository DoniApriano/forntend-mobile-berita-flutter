// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, prefer_interpolation_to_compose_strings, avoid_init_to_null, unnecessary_getters_setters, unnecessary_brace_in_string_interps, avoid_return_types_on_setters, unnecessary_this, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:flutter_application_1/screen/user_me_detail_screen.dart';
import 'package:flutter_application_1/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  String currentUsername = "";
  bool isButtonVisible = true;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? "";
    });
    if (widget.user.username == currentUsername) {
      setState(() {
        isButtonVisible = false;
      });
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

  @override
  void initState() {
    super.initState();
    getCurrentUsername();
    fetchUserFollowers();
    fetchUserFollowing();
    checkIfFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Following",
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Text(
                            "Followers",
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
              Center(
                child: Visibility(
                  visible:
                      isButtonVisible, // Tentukan apakah tombol harus ditampilkan
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFollowing) {
                        unFollow(widget.user.id);
                      } else {
                        follow(widget.user.id);
                      }
                    },
                    child: Text(isFollowing ? "Unfollow" : "Follow"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        isFollowing ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
