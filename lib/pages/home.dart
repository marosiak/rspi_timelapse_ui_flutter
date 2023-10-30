import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../components/dialogs.dart';
import '../components/info_text.dart';
import '../components/status.dart';
import '../components/system_stats.dart';
import '../models/statistics.dart';

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isTablet = (width > 980);

    return Scaffold(
      appBar: null,
      body: widget.lastUpdatedAt != null
          ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    StatusBar(lastUpdatedAt: widget.lastUpdatedAt, statistics: widget.statistics),
                    const SizedBox(height: 8),
                    StatsView(isTablet: isTablet, statistics: widget.statistics),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    RemoveFilesDialog(
                                        onAccepted: widget.askToRemoveImages),
                              ),
                              child: const Text("Remove all images"),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ))
          : Container(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.title,
      required this.channel,
      required this.statistics, this.lastUpdatedAt});

  final StatsResponse? statistics;
  final String title;
  final WebSocketChannel channel;
  final DateTime? lastUpdatedAt;

  void askToRemoveImages() {
    channel.sink.add('{"action": "REMOVE_ALL_IMAGES"}');
  }

  @override
  State<HomePage> createState() => _HomePageState();
}
