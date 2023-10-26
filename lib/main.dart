import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/pages/home.dart';
import 'package:rspi_timelapse_web/pages/login.dart';
import 'package:rspi_timelapse_web/theme.dart';


import 'package:rspi_timelapse_web/websocket/ws.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/statistics.dart';

void main() {
  runApp(MyApp());
}


class _MyAppState extends State<MyApp> {
  final websocket = Websocket('ws://localhost/ws');
  late WebSocketChannel channel = websocket.getWebSocketChannel();
  dynamic statisticsResponse;
  String? errorMsg;
  Timer ?_timer;
  bool isLogged = false;

  void readSocketData(dynamic response) {
    Map valueMap = json.decode(response);
    if (valueMap['error'] == "NOT_AUTHORISED") {
      setState(() {
        isLogged = false;
      });
    }

    if (valueMap['action'] == "AUTH"){
      if (valueMap['status'] == "SUCCESS") {
        setState(() {
          isLogged = true;
        });
      }
      if (valueMap['status'] == "WRONG_CREDENTIALS") {
        setState(() {
          errorMsg = "Wrong password";
        });
      }
    }
    if (valueMap['memory'] != null) {
      setState(() {
        statisticsResponse = StatsResponse.fromJson(valueMap);
      });
    }
    if (isLogged == true && _timer == null) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isLogged == true) {
        channel.sink.add('');
      }
    });
  }
}

@override
void initState() {
  super.initState();
  channel.stream.listen(readSocketData);
  channel.sink.add(""); // Hey ws, I am ready to understand ur communication
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Timelapse',
    theme: defaultTheme(context),
    home: isLogged
        ? HomePage(title: 'Timelapse', channel: channel, statistics: statisticsResponse)
        : LoginPage(title: "Timelapse Login", channel: channel, errorMsg: errorMsg),
  );
}}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

String abc() {
  return "";
}
