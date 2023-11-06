// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/register_page.dart';
import 'package:flutter_application_1/pages/yes.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login(String email, String password) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (!isValidEmail(email)) {
      showAlertDialog(
          context, 'Invalid Email', 'Please enter a valid email address.');
      return;
    }

    try {
      Response response = await post(
        Uri.parse('http://10.0.2.2:8000/api/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
        headers: headers,
      );

      var error = jsonDecode(response.body.toString());

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', data['token']);
        prefs.setString('username', data['data']['username']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Yes(initialIndex: 0),
          ),
        );
      } else if (error['error'] == "Email tidak ditemukan") {
        showAlertDialog(context, "Upss!!😕", "Your email is not found");
      } else if (error['error'] == "Kata sandi salah") {
        showAlertDialog(context, "Upss!!😕", "Your password is incorrect");
      } else if (error['message'] == "The password field is required.") {
        showAlertDialog(context, "Upss!!😕", error['message']);
      } else {
        var error = jsonDecode(response.body.toString());
        print(error['message']);
        print(error['error']);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selamat Datang",
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 30),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              offset: Offset.zero,
                              color: const Color.fromARGB(255, 207, 207, 207),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            label: Text("Email"),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                offset: Offset.zero,
                                color: const Color.fromARGB(255, 207, 207, 207),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.lock_clock_outlined),
                                  disabledBorder: InputBorder.none,
                                  label: Text("Password"),
                                ),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          login(
                            emailController.text.toString(),
                            passwordController.text.toString(),
                          );
                        },
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_outlined),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Masuk",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Belum punya akun?"),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              " Register",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    // Membuat ekspresi reguler untuk memeriksa alamat email
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
    );

    return emailRegex.hasMatch(email);
  }

  void showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
