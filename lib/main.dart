import 'package:flutter/material.dart';
import 'pages/first_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FirstPage(),
    theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255)),
  ));
}
