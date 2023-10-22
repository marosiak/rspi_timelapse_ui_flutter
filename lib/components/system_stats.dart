import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/responsive.dart';

abstract class StatsWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final IconData icon;
  final Map<String, String> columnMapping;
  final String unit; // Add this field

  const StatsWidget({
    super.key,
    required this.data,
    required this.title,
    required this.icon,
    required this.columnMapping,
    required this.unit, // Add this to the constructor
  });

  DataRow getDataRow(BuildContext context) {
    return DataRow(
      cells: columnMapping.keys
          .map((key) => DataCell(Text(
                '${data[key]} $unit',
                style: isPhone(context)
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyLarge,
              ))) // Use unit here
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: isPhone(context) ? EdgeInsets.all(8.0) : EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextIconHeader(icon: icon, title: title),
            DataTable(
              columnSpacing: isPhone(context) ? 10 : 25,
              columns: columnMapping.entries
                  .map((entry) => DataColumn(
                        label: Expanded(
                          child: Text(
                            entry.value,
                            style: isSmallPhone(context)
                                ? Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
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

class TextIconHeader extends StatelessWidget {
  const TextIconHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
            icon,
            size: isPhone(context) ? 32 : 38,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(title,
            style: isPhone(context)
                ? Theme.of(context)
                    .textTheme
                    .headlineSmall
                : Theme.of(context)
                    .textTheme
                    .headlineMedium)
      ],
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
          unit: '%', // Add unit here
        );
}

class RamStatsWidget extends StatsWidget {
  RamStatsWidget({super.key, required Map<String, double> ramData})
      : super(
          data: ramData,
          title: 'Ram',
          icon: Icons.dns,
          columnMapping: {
            'Total': 'Total',
            'Used': 'Used',
            'SwapTotal': 'Total Swap',
            'SwapUsed': 'Used Swap',
          },
          unit: 'MB', // Add unit here
        );
}

class MemoryStatsWidget extends StatsWidget {
  MemoryStatsWidget({super.key, required Map<String, double> memData})
      : super(
          data: memData,
          title: 'Memory',
          icon: Icons.sd_storage,
          columnMapping: {
            'Total': 'Total',
            'Free': 'Free',
          },
          unit: 'GB', // Add unit here
        );
}
