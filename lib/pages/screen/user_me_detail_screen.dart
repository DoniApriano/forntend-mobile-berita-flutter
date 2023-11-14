// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unnecessary_brace_in_string_interps, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserMeDetailScreen extends StatefulWidget {
  const UserMeDetailScreen({Key? key}) : super(key: key);

  @override
  _UserMeDetailScreenState createState() => _UserMeDetailScreenState();
}

class _UserMeDetailScreenState extends State<UserMeDetailScreen> {
  String? username = "";
  String? profilePicture = "";

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
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
      print(data);
      setState(() {
        username = data['data']['username'];
        profilePicture = data['data']['profile_picture'];
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
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Text("${username}"),
              Image.network(
                  'http://10.0.2.2:8000/storage/userProfilePicture/${profilePicture}'),
              ElevatedButton(
                onPressed: () {
                  logout();
                },
                child: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
