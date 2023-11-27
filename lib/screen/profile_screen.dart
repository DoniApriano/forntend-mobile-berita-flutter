// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unnecessary_brace_in_string_interps, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/screen/news_create_screen.dart';
import 'package:flutter_application_1/screen/notifications_screen.dart';
import 'package:flutter_application_1/screen/submission_screen.dart';
import 'package:flutter_application_1/screen/user_change_password.dart';
import 'package:flutter_application_1/screen/user_detail_screen.dart';
import 'package:flutter_application_1/screen/user_change_profile_screeen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username = "";
  String? profilePicture = "";
  String? email = "";
  bool isHovered = false;

  User user = User(id: 0, username: "", profilePicture: "", email: "");

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
  }

  Future getUser() async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        user.username = data['data']['username'].toString();
        user.id = data['data']['id'];
        user.email = data['data']['email'].toString();
        user.profilePicture = data['data']['profile_picture'].toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Profil",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Container(
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
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                image: NetworkImage(
                                  "http://10.0.2.2:8000/storage/userProfilePicture/${user.profilePicture}",
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserDetailScreen(user: user),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Colors.black,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Lihat Detail",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Menu",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserChangeProfileScreeen(user: user),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shadowColor: MaterialStatePropertyAll(Colors.grey),
                            minimumSize: MaterialStateProperty.all(
                                Size(double.infinity, 50)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Ubah Profil",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserChangePassword(user: user),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shadowColor: MaterialStatePropertyAll(Colors.grey),
                            minimumSize: MaterialStateProperty.all(
                                Size(double.infinity, 50)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Ubah Kata Sandi",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsCreateScreen(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shadowColor: MaterialStatePropertyAll(Colors.grey),
                            minimumSize: MaterialStateProperty.all(
                                Size(double.infinity, 50)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Buat Artikel",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubmissionScreen(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shadowColor: MaterialStatePropertyAll(Colors.grey),
                            minimumSize: MaterialStateProperty.all(
                                Size(double.infinity, 50)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Ajukan Permintaan",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Logout"),
                                  content: Text("Anda yakin ingin logout?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Batal"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        logout();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoginPage(),
                                          ),
                                        );
                                      },
                                      child: Text("Logout"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            shadowColor: MaterialStatePropertyAll(Colors.grey),
                            minimumSize: MaterialStateProperty.all(
                                Size(double.infinity, 50)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
