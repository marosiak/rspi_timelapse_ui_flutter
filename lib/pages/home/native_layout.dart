import 'package:flutter/material.dart';
import '../../components/dialogs.dart';
import '../../components/status.dart';
import '../../components/synchronisation.dart';
import '../../components/system_stats.dart';

import 'home.dart';

class HomePageNativeLayout extends StatelessWidget {
  HomePageNativeLayout({
    super.key,
    required this.isTablet,
    required this.homePage,
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
                    StatusBar(
                        lastUpdatedAt: homePage.lastUpdatedAt,
                        statistics: homePage.statistics),
                    const SizedBox(height: 8),
                    StatsView(
                        isTablet: isTablet, statistics: homePage.statistics),
                    ControlView(isTablet: isTablet, homePage: homePage),
                  ],
                ),
              ))
          : Container(),
    );
  }
}

class ControlView extends StatelessWidget {
  final bool isTablet;
  final HomePage homePage;

  const ControlView(
      {super.key, required this.isTablet, required this.homePage});

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SynchronisationComponent(homePage: homePage)
          ),
          Expanded(
              child: ActionsComponent(homePage: homePage)
          )
        ],
      );
    } else {
      return Column(
        children: [
          SynchronisationComponent(homePage: homePage),
          ActionsComponent(homePage: homePage)
        ],
      );
    }
  }
}





class ActionsComponent extends StatelessWidget {
  const ActionsComponent({
    super.key,
    required this.homePage,
  });

  final HomePage homePage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextIconHeader(icon: Icons.task, title: "Actions"),
            const SizedBox(height: 8,),
            RemoveFilesButton(askToRemoveImages: homePage.askToRemoveImages),
          ],
        ),
      ),
    );
  }
}
