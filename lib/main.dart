import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/pages/home.dart';
import 'package:rspi_timelapse_web/pages/login.dart';
import 'package:rspi_timelapse_web/theme.dart';
import 'package:web_socket_channel/html.dart';


void main() {
  runApp(MyApp());
}

class _MyAppState extends State<MyApp> {
  late HtmlWebSocketChannel channel;
  late Timer _timer;
  bool isLogged = false;


  void readSocketData(dynamic response){
    Map valueMap = json.decode(response);
    print("received: $response");
    if (valueMap['error'] == "NOT_AUTHORISED"){
      isLogged = false;
    }

    if( valueMap['action'] == "AUTH" && valueMap['status'] == "SUCCESS"){
      print("LOGGED SUCCES");
      isLogged = true;
      setState(() {
        isLogged = true;
      });
      print(isLogged);
    }
  }

  @override
  void initState() {
    super.initState();
    channel = HtmlWebSocketChannel.connect('ws://localhost/ws');
    channel.stream.listen(readSocketData);
    channel.sink.add(""); // Hey ws, I am ready to understand ur communication
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timelapse',
      theme: defaultTheme(context),
      home: isLogged ? HomePage(title: 'Timelapse') : LoginPage(title: "Timelapse Login", channel: channel),
    );
  }
}


class MyApp extends StatefulWidget {
  MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();


}

String abc() {
  return "";
}
