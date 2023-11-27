import 'package:flutter/material.dart';

class Custom {
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
              child: Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }
}
