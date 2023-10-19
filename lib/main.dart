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



class _DateInfo extends StatelessWidget {
  DateTime? dateToDisplay;
  String helpText;

  _DateInfo({this.dateToDisplay, required this.helpText});

  String? formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    final formatter = DateFormat('HH:mm:ss dd.MM.yyyy');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(helpText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
        ),
        SizedBox(width: 8),
        Text("${formatDateTime(dateToDisplay)}",
        )
      ],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final channel = HtmlWebSocketChannel.connect('ws://raspberrypi.local/ws');
  late Timer _timer;
  Map<String, double> _cpuStats = {'User': 0, 'System': 0, 'Idle': 0};
  Map<String, double> _memoryStats = {'Total': 0, 'Used': 0, 'SwapTotal': 0, 'SwapUsed': 0};
  DateTime? _lastUpdatedAt;
  DateTime? _lastPhotoTakenAt;

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
          _lastPhotoTakenAt = DateTime.fromMillisecondsSinceEpoch(data['lastPhotoTakenAt'] * 1000);

        }

        if (data['stats']['cpu'] != null) {
          _cpuStats = {
            'User': double.parse(data['stats']['cpu']['User'].toStringAsFixed(2)),
            'System': double.parse(data['stats']['cpu']['System'].toStringAsFixed(2)),
            'Idle': double.parse(data['stats']['cpu']['Idle'].toStringAsFixed(2)),
          };
          shouldUpdateDate = true;
        }

        if (data['stats']['memory'] != null) {
          _memoryStats = {
            'Total': double.parse(
                (data['stats']['memory']['Total'] / (1024 * 1024)).toStringAsFixed(2)),
            'Used': double.parse(
                (data['stats']['memory']['Used'] / (1024 * 1024)).toStringAsFixed(2)),
            'SwapTotal': double.parse(
                ((data['stats']['memory']['SwapTotal'] ?? data['stats']['memory']['VirtualTotal']) / (1024 * 1024)).toStringAsFixed(2)
            ),
            'SwapUsed': double.parse(
                ((data['stats']['memory']['SwapUsed'] ?? (data['stats']['memory']['VirtualTotal'] - data['stats']['memory']['VirtualFree'])) / (1024 * 1024)).toStringAsFixed(2)
            ),
          };
          shouldUpdateDate = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _lastUpdatedAt != null ? Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _DateInfo(dateToDisplay: _lastUpdatedAt, helpText: "Data updated at:"),
                    SizedBox(height: 4),
                    _DateInfo(dateToDisplay: _lastPhotoTakenAt, helpText: "Last photo taken at:"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),

            Row(
              children: [
                CpuStatsWidget(cpuData: _cpuStats),
                SizedBox(width: 48,),
                MemoryStatsWidget(memData: _memoryStats),
              ],
            ),
          ],
        ),
      ) : Container(),
    );
  }
}
