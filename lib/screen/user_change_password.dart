// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unnecessary_brace_in_string_interps, avoid_print, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom/custom.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:flutter_application_1/screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserChangePassword extends StatefulWidget {
  final User user;
  const UserChangePassword({Key? key, required this.user}) : super(key: key);

  @override
  _UserChangePasswordState createState() => _UserChangePasswordState();
}

class _UserChangePasswordState extends State<UserChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confNewPasswordController =
      TextEditingController();
  Custom _custom = Custom();

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> postChangePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;

    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    var requestBody = {
      'old_password': oldPassword.toString(),
      'new_password': newPassword.toString(),
    };

    var response = await http.post(
      Uri.parse("http://10.0.2.2:8000/api/auth/changePassword"),
      headers: headers,
      body: requestBody,
    );

    var error = json.decode(response.body.toString());

    if (response.statusCode == 200) {
      if (error['message'] == "Password lama anda tidak valid") {
        _custom.showAlertDialog(context, "Gagal", "Kata sandi lama salah");
      } else {
        _custom.showAlertDialog(
            context, "Berhasil !!", "Berhasil mengubah kata sandi");
      }
    }
    print(error);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Ubah Kata Sandi",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kata Sandi",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Keamanan adalah prioritas kami! Silakan pilih kata sandi baru yang kuat dan unik untuk melindungi akun Anda. Amankan akun Anda dengan kata sandi baru! Pilih kombinasi yang tidak terkait dengan informasi pribadi Anda untuk melindungi keamanan akun.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _oldPasswordController,
                cursorColor: Colors.grey,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Kata Sandi Lama"),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black54),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.lock_clock_outlined,
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
              child: TextField(
                controller: _newPasswordController,
                cursorColor: Colors.grey,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Kata Sandi Baru"),
                  labelStyle: TextStyle(color: Colors.black54),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.lock_open_rounded,
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
              child: TextField(
                controller: _confNewPasswordController,
                cursorColor: Colors.grey,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Konfirmasi Kata Sandi Baru"),
                  labelStyle: TextStyle(color: Colors.black54),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.lock_open_rounded,
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
                  if (_confNewPasswordController.text !=
                      _newPasswordController.text) {
                    _custom.showAlertDialog(context, "Gagal",
                        "Konfirmasi kata sandi tidak sama dengan kata sandi baru");
                  } else {
                    postChangePassword();
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confNewPasswordController.clear();
                  }
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(Size(double.infinity, 50)),
                  backgroundColor: MaterialStatePropertyAll(Colors.black),
                ),
                child: Text(
                  "Konfirmasi",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
