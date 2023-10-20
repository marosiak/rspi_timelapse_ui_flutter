import 'dart:ui';
import 'package:flutter/material.dart';

abstract class StatsWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final IconData icon;
  final Map<String, String> columnMapping;
  final String unit;  // Add this field

  StatsWidget({super.key,
    required this.data,
    required this.title,
    required this.icon,
    required this.columnMapping,
    required this.unit,  // Add this to the constructor
  });

  DataRow get dataRow {
    return DataRow(
      cells: columnMapping.keys
          .map((key) => DataCell(Text('${data[key]} $unit')))  // Use unit here
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              ],
            ),
            DataTable(
              columns: columnMapping.entries
                  .map((entry) => DataColumn(
                label: Expanded(
                  child: Text(
                    entry.value,
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
    columnMapping: {
      'Idle': 'Idle',
      'System': 'System',
      'User': 'User',
    },
    unit: '%',  // Add unit here
  );
}

class MemoryStatsWidget extends StatsWidget {
  MemoryStatsWidget({required Map<String, double> memData})
      : super(
    data: memData,
    title: 'Ram',
    icon: Icons.dns,
    columnMapping: {
      'Total': 'Total',
      'Used': 'Used',
      'SwapTotal': 'Total Swap',
      'SwapUsed': 'Used Swap',
    },
    unit: 'MB',  // Add unit here
  );
}
