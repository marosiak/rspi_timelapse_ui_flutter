import 'package:flutter/material.dart';
import '../../components/dialogs.dart';
import '../../components/status.dart';
import '../../components/system_stats.dart';
import 'home.dart';
import 'native_layout.dart';

class HomePageWebLayout extends StatelessWidget {
  HomePageWebLayout({
    super.key,
    required this.isTablet, required this.homePage,
  });

  final HomePage homePage;
  final bool isTablet;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: homePage.lastUpdatedAt != null
          ? Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                StatusBar(lastUpdatedAt: homePage.lastUpdatedAt, statistics: homePage.statistics),
                const SizedBox(height: 8),
                StatsView(isTablet: isTablet, statistics: homePage.statistics),
                ActionsComponent(homePage: homePage),
              ],
            ),
          ))
          : Container(),
    );
  }
}