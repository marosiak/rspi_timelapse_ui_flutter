import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';
import 'system_stats.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timelapse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Timelapse'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class InfoText extends StatelessWidget {
  DateTime? dateToDisplay;
  String? stringToDisplay;
  String helpText;

  InfoText({this.dateToDisplay, this.stringToDisplay, required this.helpText});

  String? formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    final formatter = DateFormat('HH:mm:ss dd.MM.yyyy');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Text(helpText,
            style: width > 375
                ? Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(stringToDisplay != null ? "${stringToDisplay}" : "${formatDateTime(dateToDisplay)}")
      ],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final channel = HtmlWebSocketChannel.connect('ws://raspberrypi.local/ws');
  // final channel = HtmlWebSocketChannel.connect('ws://localhost/ws');
  late Timer _timer;
  Map<String, double> _cpuStats = {'User': 0, 'System': 0, 'Idle': 0};
  Map<String, double> _ramStats = {
    'Total': 0,
    'Used': 0,
    'SwapTotal': 0,
    'SwapUsed': 0
  };

  Map <String, double> _memoryStats = {
    'Total': 3,
    'Free': 1,
  };
  DateTime? _lastUpdatedAt;
  DateTime? _lastPhotoTakenAt;
  String? _timeRemainingForTimelapse;

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
            'Free': double.parse((data['stats']['memory']['Free'] / (1024 * 1024 * 1024))
                .toStringAsFixed(2)),
          };
          _timeRemainingForTimelapse = data['stats']['memory']['TimeRemainingForTimelapse'];
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
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 200),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InfoText(
                  dateToDisplay: _lastUpdatedAt, helpText: "Data updated at:"
              ),
              SizedBox(height: 4),
              InfoText(
                  dateToDisplay: _lastPhotoTakenAt,
                  helpText: "Last photo taken at:"
              ),
              SizedBox(height: 4),
              InfoText(
                  stringToDisplay: _timeRemainingForTimelapse,
                  helpText: "Disk space will last for:"
              ),

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
          Expanded(
            flex: 3,
              child: CpuStatsWidget(cpuData: _cpuStats)
          ),
          Expanded(
              flex: 5,
              child: RamStatsWidget(ramData: _ramStats)
          ),
          Expanded(
              flex: 2,
              child: MemoryStatsWidget(memData: _memoryStats)
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(
              // height: 180,
              child: CpuStatsWidget(cpuData: _cpuStats)),
          // const SizedBox(width: 18),
          SizedBox(
              // height: 180,
              child: RamStatsWidget(ramData: _ramStats)),
          SizedBox(
              // height: 180,
              child: MemoryStatsWidget(memData: _memoryStats)
          ),
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
                ],
              ))
          : Container(),
    );
  }
}
