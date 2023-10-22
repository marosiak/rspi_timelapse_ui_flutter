import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/pages/home.dart';
import 'package:rspi_timelapse_web/pages/login.dart';
import 'package:rspi_timelapse_web/theme.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  bool isLogged = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Timelapse',
      theme: defaultTheme(context),
      home: isLogged ? HomePage(title: 'Timelapse') : LoginPage(title: "Timelapse Login"),
    );
  }
}

String abc() {
  return "";
}
