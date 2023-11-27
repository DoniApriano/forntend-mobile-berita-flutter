// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unnecessary_brace_in_string_interps, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/report_model.dart';
import 'package:flutter_application_1/model/submission_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Report> reportedData = [];
  List<Report> reporterData = [];
  List<Submission> submissionData = [];

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future fetchReported() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/reportCommentReported'),
        headers: headers,
      );
      var data = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        setState(() {
          reportedData = List<Report>.from(
              data['data'].map((json) => Report.fromJson(json)));
        });
      }
    } on Exception catch (e) {
      print("Error == ${e}");
    }
  }

  Future fetchReporter() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/reportCommentReporter'),
        headers: headers,
      );
      var data = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        setState(() {
          reporterData = List<Report>.from(
              data['data'].map((json) => Report.fromJson(json)));
        });
      }
    } on Exception catch (e) {
      print("Error == ${e}");
    }
  }

  Future fetchSubmission() async {
    try {
      String? token = await getToken();
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/submission'),
        headers: headers,
      );
      var data = json.decode(response.body.toString());
      print(data);
      if (response.statusCode == 200) {
        setState(() {
          submissionData = List<Submission>.from(
              data['data'].map((json) => Submission.fromJson(json)));
        });
      }
    } on Exception catch (e) {
      print("Error == ${e}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReported();
    fetchReporter();
    fetchSubmission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Notifikasi",
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: submissionData.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final submission = submissionData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                                    offset: Offset.fromDirection(-10, 5),
                                    color: const Color.fromARGB(
                                        255, 207, 207, 207),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Admin membalas pengajuan kamu tentang '${submission.request}' admin menjawab '${submission.respon}'",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: reportedData.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final report = reportedData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                                    offset: Offset.fromDirection(-10, 5),
                                    color: const Color.fromARGB(
                                        255, 207, 207, 207),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Anda telah melakukan pelanggaran ${report.description} pada komentar anda",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              report.commentText,
                                              style: TextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Pada artikel",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              report.newsTtile,
                                              style: TextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: reporterData.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final report = reporterData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                                    offset: Offset.fromDirection(-10, 5),
                                    color: const Color.fromARGB(
                                        255, 207, 207, 207),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Terima kasih telah melaporan tindakan ${report.description} pada komentar ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              report.commentText,
                                              style: TextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Pada artikel",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              report.newsTtile,
                                              style: TextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
