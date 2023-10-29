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
  DateTime? _lastUpdatedAt;

  void askToRemoveImages() {
    widget.channel.sink.add('{"action": "REMOVE_ALL_IMAGES"}');
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    setState(() {
      _lastUpdatedAt = DateTime.now();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool isTablet = (width > 980);

    return Scaffold(
      appBar: null,
      body: _lastUpdatedAt != null
          ? Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StatusBar(lastUpdatedAt: _lastUpdatedAt, statistics: widget.statistics),
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
                                        onAccepted: askToRemoveImages),
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
      required this.statistics});

  final StatsResponse? statistics;
  final String title;
  final WebSocketChannel channel;

  @override
  State<HomePage> createState() => _HomePageState();
}
