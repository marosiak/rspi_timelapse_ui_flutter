
import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/pages/home/web_layout.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../components/dialogs.dart';
import '../../components/status.dart';
import '../../main.dart';
import '../../models/statistics.dart';
import 'native_layout.dart';

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isTablet = (width > 980);

    return kIsWeb
        ? HomePageWebLayout(isTablet: isTablet, homePage: widget)
        : HomePageNativeLayout(isTablet: isTablet, homePage: widget);
  }
}





class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.title,
      required this.channel,
      required this.statistics, this.lastUpdatedAt, required this.subscribeFunc, required this.unsubscribeFunc});

  final StatsResponse? statistics;
  final String title;
  final WebSocketChannel channel;
  final DateTime? lastUpdatedAt;
  final SubscribeFunction subscribeFunc;
  final SubscribeFunction unsubscribeFunc;
  void askToRemoveImages() {
    channel.sink.add('{"action": "REMOVE_ALL_IMAGES"}');
  }

  void subscribeToPhotos() {
    subscribeFunc(photosTopic);
  }

  void unsubscribePhotos() {
    unsubscribeFunc(photosTopic);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}
