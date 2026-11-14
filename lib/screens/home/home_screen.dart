import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';
import '../detail/incident_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onSeeAll,
    required this.onReport,
  });

  final VoidCallback onSeeAll;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProvider).asData?.value;
    final authUser = ref.watch(authStateProvider).asData?.value;
    final isStaff = profile?.isStaff ?? false;
    final incidents = ref.watch(dashboardIncidentsProvider);
    final stats = ref.watch(dashboardStatsProvider);

    final firstName = (profile != null && profile.firstName.isNotEmpty)
        ? profile.firstName
        : (authUser?.displayName?.split(' ').first ?? 'there');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hello, $firstName \u{1F44B}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isStaff)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'STAFF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    profile?.initials ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Help make our campus safer.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Report issues and track their resolution.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _HeroCard(onReport: onReport),
            const SizedBox(height: 24),
            SectionHeader(
              title: isStaff ? 'Campus Summary' : 'Report Summary',
              actionLabel: 'See all',
              onAction: onSeeAll,
            ),
            const SizedBox(height: 12),
            StatsRow(
              stats: stats,
              totalLabel: isStaff ? 'All Reports' : 'My Reports',
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recent Reports',
              actionLabel: 'See all',
              onAction: onSeeAll,
            ),
            const SizedBox(height: 12),
            incidents.when(
              data: (list) => _RecentList(incidents: list, onReport: onReport),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: LoadingView(),
              ),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () {
                  ref.invalidate(allIncidentsProvider);
                  ref.invalidate(myIncidentsProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.incidents, required this.onReport});

  final List<Incident> incidents;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return Column(
        children: [
          const EmptyState(
            icon: Icons.campaign_rounded,
            title: 'No reports yet',
            message: 'Seen something that needs fixing? '
                'Submit your first report.',
          ),
          OutlinedButton.icon(
            onPressed: onReport,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Report an Issue'),
          ),
        ],
      );
    }

    final recent = incidents.take(3).toList();
    return Column(
      children: [
        for (var i = 0; i < recent.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          IncidentCard(
            incident: recent[i],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    IncidentDetailScreen(incidentId: recent[i].id),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'See an issue\non campus?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Report it and help improve our learning environment.',
                      style: TextStyle(
                        color: Color(0xFFE6E0FF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onReport,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Report an Issue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
