import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rspi_timelapse_web/models/statistics.dart';
import 'package:rspi_timelapse_web/responsive.dart';

abstract class StatsWidget extends StatelessWidget {
  final Map<String, String> data;
  final String title;
  final IconData icon;
  final Map<String, String> columnMapping;
  final String unit;

  const StatsWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.icon,
    required this.columnMapping,
    required this.unit,
  }) : super(key: key);

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
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextIconHeader(icon: icon, title: title),
            DataTable(
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
  final IconData icon;
  final String title;

  const TextIconHeader({Key? key, required this.icon, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 8.0),
        Text(title),
      ],
    );
  }
}

class CpuStatsWidget extends StatsWidget {
  CpuStatsWidget({required Cpu cpu})
      : super(
    data: {
      'User': cpu.userToPercent(),
      'System': cpu.systemToPercent(),
      'Idle': cpu.idleToPercent(),
    },
    title: 'CPU',
    icon: Icons.memory,
    columnMapping: {
      'User': 'User',
      'System': 'System',
      'Idle': 'Idle',
    },
    unit: '%',
  );
}

class RamStatsWidget extends StatsWidget {
  RamStatsWidget({required Ram ram})
      : super(
    data: {
      'Total': ram.totalToGB(),
      'Free': ram.freeToGB(),
      'SwapTotal': ram.swapTotalToString(),
      'SwapUsed': ram.swapUsedToString(),
    },
    title: 'RAM',
    icon: Icons.dns,
    columnMapping: {
      'Total': 'Total',
      'Free': 'Free',
      'SwapTotal': 'Total Swap',
      'SwapUsed': 'Used Swap',
    },
    unit: 'GB',
  );
}

class MemoryStatsWidget extends StatsWidget {
  MemoryStatsWidget({required Memory memory})
      : super(
    data: {
      'Total': memory.totalToGB(),
      'Free': memory.freeToGB(),
    },
    title: 'Memory',
    icon: Icons.sd_storage,
    columnMapping: {
      'Total': 'Total',
      'Free': 'Free',
    },
    unit: 'GB',
  );
}