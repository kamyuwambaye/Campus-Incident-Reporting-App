import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_bottom_bar.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'report/report_incident_screen.dart';
import 'reports/reports_screen.dart';

/// Bottom-navigation container for the signed-in experience. The selected
/// tab is ephemeral UI state, so a local setState is appropriate here; all
/// shared application state lives in Riverpod providers.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  void _openReportForm() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReportIncidentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onSeeAll: () => _goTo(1), onReport: _openReportForm),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomBar(
        index: _index,
        onTap: _goTo,
        onReport: _openReportForm,
      ),
    );
  }
}
