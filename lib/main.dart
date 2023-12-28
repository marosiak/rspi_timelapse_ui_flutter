import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/pages/home/home.dart';
import 'package:rspi_timelapse_web/pages/login.dart';
import 'package:rspi_timelapse_web/theme.dart';


import 'package:rspi_timelapse_web/websocket/ws.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/statistics.dart';

void main() {
  runApp(MyApp());
}

const photosTopic = "PHOTOS";
const statsTopic = "STTISTICS";

typedef SubscribeFunction = void Function(String topic);


class _MyAppState extends State<MyApp> {
  // final websocket = Websocket('ws://raspberrypi.local/ws');
  final websocket = Websocket('ws://localhost/ws');
  late WebSocketChannel channel = websocket.getWebSocketChannel();
  dynamic statisticsResponse;
  String? errorMsg;
  bool isLogged = false;
  DateTime ?lastUpdatedAt;

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
        lastUpdatedAt = DateTime.now();
      });
    }
}

  void subscribe(String topic) {
    channel.sink.add('{"action": "SUBSCRIBE", "value": "$topic"}');
  }

  void unsubscribe(String topic) {
    channel.sink.add('{"action": "UNSUBSCRIBE", "value": "$topic"}');
  }

@override
void initState() {
  super.initState();
  channel.stream.listen(readSocketData);
  channel.sink.add(""); // Hey ws, I am ready to understand ur communication //TODO is it needed?
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Timelapse',
    theme: defaultTheme(context),
    home: isLogged && lastUpdatedAt != null
        ? HomePage(
        title: 'Timelapse',
        channel: channel,
        statistics: statisticsResponse,
        lastUpdatedAt: lastUpdatedAt,
        subscribeFunc: subscribe,
      unsubscribeFunc: unsubscribe,
    )
        : LoginPage(title: "Timelapse Login", channel: channel, errorMsg: errorMsg),
  );
}}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

