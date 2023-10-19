import 'dart:ui';

import 'package:flutter/material.dart';

class CpuStatsWidget extends StatelessWidget {
  final Map<String, double> cpuData;

  CpuStatsWidget({required this.cpuData});

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
        ),
      ),
    );
  }
}

class MemoryStatsWidget extends StatelessWidget {
  final Map<String, double> memData;

  MemoryStatsWidget({required this.memData});

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.dns, size: 35),
                SizedBox(width: 8),
                Text("Ram",
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
        ),
      ),
    );
  }
}