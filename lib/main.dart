import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';

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

class _CpuStatsWidget extends StatelessWidget {
  final Map<String, double> cpuData;

  _CpuStatsWidget({required this.cpuData});

  DataRow get _dataRow {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('${cpuData['Idle']}%')),
        DataCell(Text('${cpuData['System']}%')),
        DataCell(Text('${cpuData['User']}%')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.memory, size: 35),
            SizedBox(width: 8),
            Text("CPU",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          ],
        ),
        DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Expanded(
                child: Text(
                  'Free',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'System',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'User',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: <DataRow>[_dataRow],
        )
      ],
    );
  }
}

class _MemoryStatsWidget extends StatelessWidget {
  final Map<String, double> memData;

  _MemoryStatsWidget({required this.memData});

  DataRow get _dataRow {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text('${memData['Total']} MB')),
        DataCell(Text('${memData['Used']} MB')),
        DataCell(Text('${memData['SwapTotal']} MB')),
        DataCell(Text('${memData['SwapUsed']} MB')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.dns, size: 35),
            SizedBox(width: 8),
            Text("Memory",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          ],
        ),
        DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Used',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Swap Total',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Swap Used',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          rows: <DataRow>[_dataRow],
        )
      ],
    );
  }
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
        child: FittedBox(
          fit: BoxFit.fill,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Column(
              children: [
                _DateInfo(dateToDisplay: _lastUpdatedAt, helpText: "Data updated at:"),
                SizedBox(height: 4),
                _DateInfo(dateToDisplay: _lastPhotoTakenAt, helpText: "Last photo taken at:"),
                SizedBox(height: 8),

                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.fitWidth,
                        child: _CpuStatsWidget(cpuData: _cpuStats)
                    ),
                    SizedBox(width: 48,),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                        child: _MemoryStatsWidget(memData: _memoryStats)
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) : Container(),
    );
  }
}
