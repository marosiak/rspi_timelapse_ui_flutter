import 'package:flutter/material.dart';

import '../models/statistics.dart';
import 'info_text.dart';

class StatusBar extends StatelessWidget {
  final DateTime? lastUpdatedAt;
  final StatsResponse? statistics;

  const StatusBar({super.key, this.lastUpdatedAt, this.statistics});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InfoText(
                  dateToDisplay: lastUpdatedAt, helpText: "Data updated at:"),
              const SizedBox(height: 4),
              InfoText(
                  dateToDisplay: statistics!.lastPhotoTakenAt,
                  helpText: "Last photo taken at:"),
              const SizedBox(height: 4),
              InfoText(
                  stringToDisplay:
                  statistics?.memory?.timeRemainingForTimelapse,
                  helpText: width < 430
                      ? "Disk space for:"
                      : "Disk space will last for:"),
            ],
          ),
        ),
      ),
    );
  }
}
