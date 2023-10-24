import 'dart:html';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../responsive.dart';

class InfoText extends StatelessWidget {
  DateTime? dateToDisplay;
  String? stringToDisplay;
  String helpText;

  InfoText(
      {super.key,
        this.dateToDisplay,
        this.stringToDisplay,
        required this.helpText});

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
            style: isSmallPhone(context)
                ? Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(stringToDisplay != null
            ? "${stringToDisplay}"
            : "${formatDateTime(dateToDisplay)}")
      ],
    );
  }
}