// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unnecessary_brace_in_string_interps, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom/custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({Key? key}) : super(key: key);

  @override
  _SubmissionScreenState createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  TextEditingController _submissionController = TextEditingController();
  Custom _custom = Custom();

  // Future<void> getCurrentEmail() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     currentEmail = prefs.getString('email') ?? "";
  //   });
  // }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future postSubmission() async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    var requestBody = {
      'text': _submissionController.text,
    };
    var response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/submission'),
      headers: headers,
      body: requestBody,
    );

    var data = json.decode(response.body);
    if (data['message'].contains("Berhasil")) {
      _custom.showAlertDialog(context, "Berhasil", "Berhasil melapor");
      _submissionController.clear();
    } else {
      print(data);
      print("status code = ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Ajukan Permintaan",
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
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: ExtendedTextField(
                controller: _submissionController,
                cursorColor: Colors.grey,
                maxLines: 5,
                decoration: InputDecoration(
                  label: Text("Laporan"),
                  labelStyle: TextStyle(color: Colors.black54),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.article_rounded,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  postSubmission();
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(Size(double.infinity, 50)),
                  backgroundColor: MaterialStatePropertyAll(Colors.black),
                ),
                child: Text(
                  "Konfirmasi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
