import 'dart:ui';
import 'package:flutter/material.dart';

abstract class StatsWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final IconData icon;
  final List<String> columnNames;

  StatsWidget({
    required this.data,
    required this.title,
    required this.icon,
    required this.columnNames,
  });

  DataRow get dataRow {
    return DataRow(
      cells: columnNames
          .map((columnName) => DataCell(Text('${data[columnName]}')))
          .toList(),
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
            Row(
              children: [
                Icon(icon, size: 35),
                SizedBox(width: 8),
                Text(title,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              ],
            ),
            DataTable(
              columns: columnNames
                  .map((columnName) => DataColumn(
                label: Expanded(
                  child: Text(
                    columnName,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ))
                  .toList(),
              rows: <DataRow>[dataRow],
            ),
          ],
        ),
      ),
    );
  }
}

class CpuStatsWidget extends StatsWidget {
  CpuStatsWidget({required Map<String, double> cpuData})
      : super(
    data: cpuData,
    title: 'CPU',
    icon: Icons.memory,
    columnNames: ['Idle', 'System', 'User'],
  );
}

class MemoryStatsWidget extends StatsWidget {
  MemoryStatsWidget({required Map<String, double> memData})
      : super(
    data: memData,
    title: 'Ram',
    icon: Icons.dns,
    columnNames: ['Total', 'Used', 'SwapTotal', 'SwapUsed'],
  );
}
