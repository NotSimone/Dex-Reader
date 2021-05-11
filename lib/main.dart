import 'package:flutter/material.dart';
import 'src/MainPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Dex Reader",
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: MainPage());
  }
}
