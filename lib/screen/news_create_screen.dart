// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print, prefer_interpolation_to_compose_strings, prefer_final_fields, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom/custom.dart';
import 'package:flutter_application_1/model/category_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:extended_text_field/extended_text_field.dart';

class NewsCreateScreen extends StatefulWidget {
  const NewsCreateScreen({Key? key}) : super(key: key);

  @override
  NewsCreateScreenState createState() => NewsCreateScreenState();
}

class NewsCreateScreenState extends State<NewsCreateScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _newsContentController = TextEditingController();
  File? image;
  Custom _custom = Custom();
  List<Category> categoryData = [];
  String? selectedCategoryId;

  Future<void> postNews() async {
    final title = _titleController.text;
    final newsContent = _newsContentController.text;
    final cateogryId = selectedCategoryId;
    String? token = await getToken();

    if (image == null) {
      _custom.showAlertDialog(
          context, "Gagal Mendaftar", "Anda perlu memilih gambar artikel.");
      return;
    }

    var stream = new http.ByteStream(image!.openRead());
    stream.cast();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/news'),
    );

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${token}';
    request.fields['title'] = title;
    request.fields['news_content'] = newsContent;
    request.fields['category_id'] = cateogryId.toString();

    var imageField = await http.MultipartFile.fromPath('image', image!.path);
    request.files.add(imageField);

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      final String message = data['message'];
      print(data);

      if (message.contains('Berhasil')) {
        setState(() {
          _titleController.text = '';
          _newsContentController.text = '';
          image = null;
          selectedCategoryId = null;
        });

        _custom.showAlertDialog(
            context, 'Berhasil', "Berhasil menambahkan artikel");
      } else if (message.contains("The title field is required.")) {
        _custom.showAlertDialog(
            context, 'Gagal', "Judulnya jangan dikosongin dong");
      } else if (message.contains("The news content field is required")) {
        _custom.showAlertDialog(
            context, 'Gagal', "Konten Artikelnya jangan lupa diisi ya");
      } else if (message.contains("The image field is required")) {
        _custom.showAlertDialog(
            context, 'Gagal', "Gambarnya jangan lupa diisi ya");
      } else if (message.contains("The category id field is required")) {
        _custom.showAlertDialog(
            context, 'Gagal', "Kategori jangan lupa diisi ya");
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
      });
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getCategory() async {
    String? token = await getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/category'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body.toString());
      setState(() {
        categoryData = List<Category>.from(
            data['data'].map((json) => Category.fromJson(json)));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Buat Artikel",
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
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: _pickImage,
                child: image == null
                    ? Container(
                        width: 350,
                        height: 200,
                        color: Colors.grey,
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                    : Image.file(
                        File(image!.path),
                        width: 350,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _titleController,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  label: Text("Judul"),
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
              child: ExtendedTextField(
                controller: _newsContentController,
                cursorColor: Colors.grey,
                maxLines: 5,
                decoration: InputDecoration(
                  label: Text("Konten Artikel"),
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
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  label: Text("Kategori"),
                  labelStyle: TextStyle(color: Colors.black54),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.category_rounded,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categoryData.map((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.id.toString(),
                    child: Text(category.name),
                  );
                }).toList(),
                iconSize: 5,
                onChanged: (String? value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  postNews();
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
