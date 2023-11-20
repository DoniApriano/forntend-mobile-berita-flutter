// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, library_private_types_in_public_api, unnecessary_brace_in_string_interps, avoid_print, prefer_const_literals_to_create_immutables, prefer_final_fields, unnecessary_string_interpolations, use_build_context_synchronously, unnecessary_new

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserUpdateProfileScreeen extends StatefulWidget {
  final User user;
  const UserUpdateProfileScreeen({Key? key, required this.user})
      : super(key: key);

  @override
  _UserUpdateProfileScreeenState createState() =>
      _UserUpdateProfileScreeenState();
}

class _UserUpdateProfileScreeenState extends State<UserUpdateProfileScreeen> {
  TextEditingController _usernameController = TextEditingController();
  File? image;
  String? profilePictureUrl;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> postUpdateProfil() async {
    final username = _usernameController.text;
    String? token = await getToken();

    if (image == null) {
      showAlertDialog(
          context, "Gagal Mendaftar", "Anda perlu memilih gambar profil.");
      return;
    }

    final Map<String, dynamic> data = {
      'username': username,
    };

    final jsonData = json.encode(data); // Mengonversi data ke JSON

    var stream = new http.ByteStream(image!.openRead());
    stream.cast();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/user/update'),
    );

    // Tambahkan header 'Content-Type' untuk JSON
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${token}';
    request.fields['username'] = username;

    request.fields['data'] = jsonData;

    // Tambahkan gambar ke permintaan
    var imageField =
        await http.MultipartFile.fromPath('profile_picture', image!.path);
    request.files.add(imageField);

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      final String message = data['message'];
      print(data);

      if (message.contains('Berhasil')) {
        showAlertDialog(context, 'Berhasil', "Berhasil Update");
      } else if (message.contains('validation.square_image')) {
        showAlertDialog(
            context, 'Gagal', "Foto Profil yang digunakan harus 1:1");
      }
    } catch (e) {
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
        profilePictureUrl = null;
      });
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

  @override
  void initState() {
    super.initState();
    _usernameController.text = "${widget.user.username.toString()}";
    profilePictureUrl =
        "http://10.0.2.2:8000/storage/userProfilePicture/${widget.user.profilePicture}";
    print(profilePictureUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Ubah Profil",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                  onTap: _pickImage,
                  child: image == null
                      ? Image.network(
                          profilePictureUrl!,
                          width: 200,
                          height: 200,
                        )
                      : Image.file(
                          File(image!.path),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _usernameController,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  label: Text("Username"),
                  labelStyle: TextStyle(color: Colors.black54),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.person_2_rounded,
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
                  postUpdateProfil();
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(Size(double.infinity, 50)),
                  backgroundColor: MaterialStatePropertyAll(Colors.black),
                ),
                child: Text("Konfirmasi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
