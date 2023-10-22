// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Selamat datang di Pawarta",
          body:
              "Pawarta, sumber berita terkini dan terpercaya yang akan membawa Anda ke dalam dunia berita dengan cakupan luas dan mendalam. Pawarta adalah teman setia Anda dalam memahami peristiwa terbaru, tren, dan informasi penting yang memengaruhi dunia hari ini",
          image: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Lottie.asset("assets/lotties/news.json"),
            ),
          ),
        ),
        PageViewModel(
          title: "Menyebar informasi tanpa HOAX",
          body:
              "Kami tahu bahwa dunia informasi saat ini penuh dengan informasi yang tidak terverifikasi, desas-desus, dan hoaks. Itulah mengapa Pawarta hadir, untuk menjadi teman setia Anda dalam menjelajahi berita. Dengan tim jurnalis berpengalaman dan teknologi terkini, kami menyajikan berita yang bisa Anda andalkan.",
          image: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Lottie.asset("assets/lotties/hoax.json"),
            ),
          ),
        ),
      ],
      done: const Text(
        "Masuk",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      showNextButton: true,
      showBackButton: true,
      back: Text("<< Back"),
      next: Text("Next >>"),
      onDone: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      },
    );
  }
}
