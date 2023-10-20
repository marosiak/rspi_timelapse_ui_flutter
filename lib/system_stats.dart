import 'dart:ui';
import 'package:flutter/material.dart';

abstract class StatsWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final IconData icon;
  final Map<String, String> columnMapping;
  final String unit;  // Add this field

  const StatsWidget({super.key,
    required this.data,
    required this.title,
    required this.icon,
    required this.columnMapping,
    required this.unit,  // Add this to the constructor
  });

  bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 595;
  }

  DataRow getDataRow(BuildContext context) {
    return DataRow(
      cells: columnMapping.keys
          .map((key) => DataCell(
          Text(
            '${data[key]} $unit',
            style: isPhone(context) ? Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodyLarge,
          )
      ))  // Use unit here
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
                Icon(icon, size:
                isPhone(context) ? 32 : 38
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: isPhone(context)
                      ? Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                      : Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
                )
              ],
            ),
            DataTable(
              columnSpacing: isPhone(context) ? 10 :  25,
              columns: columnMapping.entries
                  .map((entry) => DataColumn(
                label: Expanded(
                  child: Text(
                    entry.value,
                    style: isPhone(context)
                        ? Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)
                        : Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ))
                  .toList(),
              rows: [getDataRow(context)],
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
