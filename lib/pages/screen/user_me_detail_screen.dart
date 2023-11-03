import 'package:flutter/material.dart';

class UserMeDetailScreen extends StatefulWidget {
  const UserMeDetailScreen({Key? key}) : super(key: key);

  @override
  _UserMeDetailScreenState createState() => _UserMeDetailScreenState();
}

class _UserMeDetailScreenState extends State<UserMeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("User me"),
        ),
      ),
    );
  }
}
