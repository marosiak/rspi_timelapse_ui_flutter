import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/html.dart';

import '../components/dialogs.dart';
import '../components/info_text.dart';
import '../components/system_stats.dart';

class _HomePageState extends State<HomePage> {
  // final channel = HtmlWebSocketChannel.connect('ws://raspberrypi.local/ws');

  final channel = HtmlWebSocketChannel.connect('ws://localhost/ws',);


  late Timer _timer;
  Map<String, double> _cpuStats = {'User': 0, 'System': 0, 'Idle': 0};
  Map<String, double> _ramStats = {
    'Total': 0,
    'Used': 0,
    'SwapTotal': 0,
    'SwapUsed': 0
  };

  Map<String, double> _memoryStats = {
    'Total': 3,
    'Free': 1,
  };
  DateTime? _lastUpdatedAt;
  DateTime? _lastPhotoTakenAt;
  String? _timeRemainingForTimelapse;

  void askToRemoveImages() {
    channel.sink.add('{"action": "REMOVE_ALL_IMAGES"}');
  }

  void authWebsocket() {
    channel.sink.add('{"action": "AUTH", "value": "2137"}');
  }

  @override
  void initState() {
    super.initState();
    channel.sink.add('');

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      channel.sink.add('');
    });

    channel.stream.listen((response) {
      final Map<String, dynamic> data = jsonDecode(response);
      bool shouldUpdateDate = false;

      setState(() {
        if (data['lastPhotoTakenAt'] != null) {
          _lastPhotoTakenAt = DateTime.fromMillisecondsSinceEpoch(
              data['lastPhotoTakenAt'] * 1000);
        }

        if (data['stats']['cpu'] != null) {
          _cpuStats = {
            'User':
            double.parse(data['stats']['cpu']['User'].toStringAsFixed(2)),
            'System':
            double.parse(data['stats']['cpu']['System'].toStringAsFixed(2)),
            'Idle':
            double.parse(data['stats']['cpu']['Idle'].toStringAsFixed(2)),
          };
          shouldUpdateDate = true;
        }

        if (data['stats']['ram'] != null) {
          _ramStats = {
            'Total': double.parse(
                (data['stats']['ram']['Total'] / (1024 * 1024))
                    .toStringAsFixed(2)),
            'Used': double.parse((data['stats']['ram']['Used'] / (1024 * 1024))
                .toStringAsFixed(2)),
            'SwapTotal': double.parse(((data['stats']['ram']['SwapTotal'] ??
                data['stats']['ram']['VirtualTotal']) /
                (1024 * 1024))
                .toStringAsFixed(2)),
            'SwapUsed': double.parse(((data['stats']['ram']['SwapUsed'] ??
                (data['stats']['ram']['VirtualTotal'] -
                    data['stats']['ram']['VirtualFree'])) /
                (1024 * 1024))
                .toStringAsFixed(2)),
          };
          shouldUpdateDate = true;
        }

        if (data['stats']['memory'] != null) {
          _memoryStats = {
            'Total': double.parse(
                (data['stats']['memory']['Total'] / (1024 * 1024 * 1024))
                    .toStringAsFixed(2)),
            'Free': double.parse(
                (data['stats']['memory']['Free'] / (1024 * 1024 * 1024))
                    .toStringAsFixed(2)),
          };
          _timeRemainingForTimelapse =
          data['stats']['memory']['TimeRemainingForTimelapse'];
        }

        if (shouldUpdateDate) {
          _lastUpdatedAt = DateTime.now();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    channel.sink.close();
    super.dispose();
  }

  Widget _getStatusBar() {
    double width = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 200),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InfoText(
                  dateToDisplay: _lastUpdatedAt, helpText: "Data updated at:"),
              SizedBox(height: 4),
              InfoText(
                  dateToDisplay: _lastPhotoTakenAt,
                  helpText: "Last photo taken at:"),
              SizedBox(height: 4),
              InfoText(
                  stringToDisplay: _timeRemainingForTimelapse,
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
    if (isHorizontal) {
      return Row(
        children: [
          Expanded(flex: 3, child: CpuStatsWidget(cpuData: _cpuStats)),
          Expanded(flex: 6, child: RamStatsWidget(ramData: _ramStats)),
          Expanded(flex: 3, child: MemoryStatsWidget(memData: _memoryStats)),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(child: CpuStatsWidget(cpuData: _cpuStats)),
          SizedBox(child: RamStatsWidget(ramData: _ramStats)),
          SizedBox(child: MemoryStatsWidget(memData: _memoryStats)),
        ],
      );
    }
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
          child: Column(
            children: [
              _getStatusBar(),
              const SizedBox(height: 8),
              _getWidgets(isTablet),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) =>
                              RemoveFilesDialog(
                                  onAccepted: askToRemoveImages),
                        ),
                        child: Text("Remove all images"),
                      )
                    ],
                  ),
                ),
              )
            ],
          ))
          : Container(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}