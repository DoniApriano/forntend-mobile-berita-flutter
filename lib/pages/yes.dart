// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/fragments/page1.dart';

class Yes extends StatefulWidget {
  const Yes({Key? key}) : super(key: key);

  @override
  State<Yes> createState() => _YesState();
}

class _YesState extends State<Yes> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> myWidget = [
      Center(
        child: Page1(),
      ),
      Center(
          child: Text(
        "Halaman 2",
        style: TextStyle(fontSize: 20),
      )),
      Center(
          child: Text(
        "Halaman 3",
        style: TextStyle(fontSize: 20),
      )),
      Center(
          child: Text(
        "Halaman 4",
        style: TextStyle(fontSize: 20),
      )),
    ];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Main Activity")),
        body: myWidget[currentIndex],
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: Colors.white,
          items: [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.map, title: 'Discovery'),
            TabItem(icon: Icons.add, title: 'Add'),
            TabItem(icon: Icons.person, title: 'My Account'),
          ],
          activeColor: Colors.blue,
          onTap: (int i) {
            setState(() {
              currentIndex = i;
            });
          },
          color: Colors.blue,
        ),
      ),
    );
  }
}
