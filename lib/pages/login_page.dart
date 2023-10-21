// ignore_for_file: use_key_in_widget_constructors, avoid_print, use_build_context_synchronously, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/yes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      String token = await loginUser(email, password) ?? "";
      await saveToken(token);

      // Pindah ke halaman berikutnya
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return Yes();
        },
      ));
    } catch (error) {
      // Tangani kesalahan login di sini
      print('Gagal login: $error');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> loginUser(String email, String password) async {
    final response =
        await Dio().post('http://10.0.2.2:8000/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      // Tangkap token dari respons dan kembalikan token
      String token = response.data['token'];
      return token;
    } else {
      throw Exception('Gagal login');
    }
  }
}
