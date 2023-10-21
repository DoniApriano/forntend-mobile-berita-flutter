// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Halaman 1"),
            ElevatedButton(
              onPressed: () {
                logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  },
                ));
              },
              child: Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}
