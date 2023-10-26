import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../components/dialogs.dart';
import '../components/info_text.dart';
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

  Widget _getStatusBar(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InfoText(
                  dateToDisplay: _lastUpdatedAt, helpText: "Data updated at:"),
              const SizedBox(height: 4),
              InfoText(
                  dateToDisplay: widget.statistics!.lastPhotoTakenAt,
                  helpText: "Last photo taken at:"),
              const SizedBox(height: 4),
              InfoText(
                  stringToDisplay:
                      widget.statistics?.memory?.timeRemainingForTimelapse,
                  helpText: width < 430
                      ? "Disk space for:"
                      : "Disk space will last for:"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWidgets(bool isHorizontal) {
    if (widget.statistics == null ||
        widget.statistics!.cpu == null ||
        widget.statistics!.ram == null ||
        widget.statistics!.memory == null) {
      return Container();
    }
    if (isHorizontal) {
      return Row(
        children: [
          Expanded(
              flex: 4, child: CpuStatsWidget(cpu: widget.statistics!.cpu!)),
          Expanded(
              flex: 7, child: RamStatsWidget(ram: widget.statistics!.ram!)),
          Expanded(
              flex: 3,
              child: MemoryStatsWidget(memory: widget.statistics!.memory!)),
        ],
      );
    } else {
      return Column(
        children: [
          CpuStatsWidget(cpu: widget.statistics!.cpu!),
          RamStatsWidget(ram: widget.statistics!.ram!),
          MemoryStatsWidget(memory: widget.statistics!.memory!),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool isTablet = (width > 980);

    // String? selectedDirectory;
    return Scaffold(
      appBar: null,
      body: _lastUpdatedAt != null
          ? Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _getStatusBar(context),
                    const SizedBox(height: 8),
                    _getWidgets(isTablet),
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
                            // ElevatedButton(
                            //     onPressed: () async => (
                            //       selectedDirectory = FilePicker.platform.getDirectoryPath() as String?
                            //
                            //     ),
                            //   child: Text("Download files $selectedDirectory"),
                            // ),
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
