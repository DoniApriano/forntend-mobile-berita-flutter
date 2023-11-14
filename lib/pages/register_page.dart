// ignore_for_file: unnecessary_new, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  File? image;

  CustomColor customColor = CustomColor();

  Future<void> registerUser() async {
    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (image == null) {
      showAlertDialog(
          context, "Gagal Mendaftar", "Anda perlu memilih gambar profil.");
      return;
    }

    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
      // Tambahkan data lain sesuai kebutuhan
    };

    final jsonData = json.encode(data); // Mengonversi data ke JSON

    var stream = new http.ByteStream(image!.openRead());
    stream.cast();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/auth/register'),
    );

    // Tambahkan header 'Content-Type' untuk JSON
    request.headers['Accept'] = 'application/json';
    request.fields['username'] = username;
    request.fields['password'] = password;
    request.fields['email'] = email;
    request.fields['password_confirmation'] = confirmPassword;

    // Tambahkan data JSON sebagai bagian dari permintaan
    request.fields['data'] = jsonData;

    // Tambahkan gambar ke permintaan
    var imageField =
        await http.MultipartFile.fromPath('profile_picture', image!.path);
    request.files.add(imageField);

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      final String message = data['message'];
      print(data);

      if (message.contains('Berhasil Register')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else if (message.contains('The email field is required.')) {
        showAlertDialog(context, 'Gagal Mendaftar', "Harap isi email anda");
      } else if (message.contains('The email has already been taken.')) {
        showAlertDialog(
            context, "Gagal Mendaftar", "Email anda sudah digunakan");
      } else if (message.contains("The password field is required.")) {
        showAlertDialog(context, "Gagal Mendaftar", "Harap isi password anda");
      } else if (password != confirmPassword) {
        showAlertDialog(context, "Gagal Mendaftar", "Password tidak cocok");
      }
    } catch (e) {
      // Tangani kesalahan selain dari respons yang tidak valid.
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: customColor.grey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Silahkan melakukan Register",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 30,
                  color: customColor.dark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: image == null
                            ? Container(
                                width: 200,
                                height: 200,
                                color: customColor.purple,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              )
                            : Image.file(
                                File(image!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
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
                          controller: usernameController,
                          decoration: InputDecoration(
                            label: Text("Username"),
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              color: customColor.purple,
                            ),
                            prefixIconColor: customColor.purple,
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                    ),
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
                            label: Text("Email"),
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              color: customColor.purple,
                            ),
                            prefixIconColor: customColor.purple,
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                    ),
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
                        child: Column(
                          children: [
                            TextFormField(
                              obscureText: true,
                              controller: passwordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelStyle: TextStyle(
                                  color: customColor.purple,
                                ),
                                prefixIconColor: customColor.purple,
                                label: Text("Kata sandi"),
                                prefixIcon: Icon(Icons.lock_clock_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                        child: Column(
                          children: [
                            TextFormField(
                              obscureText: true,
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelStyle: TextStyle(
                                  color: customColor.purple,
                                ),
                                prefixIconColor: customColor.purple,
                                label: Text("Konfirmasi Kata Sandi"),
                                prefixIcon: Icon(Icons.lock_clock_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          registerUser();
                        },
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(10),
                          backgroundColor:
                              MaterialStateProperty.all(customColor.purple),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_outlined),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Daftar",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
