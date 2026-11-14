import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';
import '../detail/incident_detail_screen.dart';

/// "My Reports": profile header, personal stats, status filter and the
/// signed-in user's own reports. Also hosts sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProvider).asData?.value;
    final authUser = ref.watch(authStateProvider).asData?.value;
    final stats = ref.watch(myStatsProvider);
    final selectedStatus = ref.watch(myReportsStatusProvider);
    final reports = ref.watch(filteredMyIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _ProfileHeader(
            name: profile?.name ?? authUser?.displayName ?? 'Campus member',
            email: profile?.email ?? authUser?.email ?? '',
            department: profile?.department ?? '',
            role: profile?.role ?? UserRole.student,
            initials: profile?.initials ?? '?',
          ),
          const SizedBox(height: 16),
          StatsRow(
            stats: stats,
            totalLabel: 'Total Reports',
            showSubmitted: false,
          ),
          const SizedBox(height: 20),
          FilterChipRow<IncidentStatus>(
            options: IncidentStatus.values,
            selected: selectedStatus,
            labelOf: (s) => s.label,
            horizontalPadding: 0,
            onSelected: ref.read(myReportsStatusProvider.notifier).select,
          ),
          const SizedBox(height: 14),
          reports.when(
            data: (list) {
              if (list.isEmpty) {
                return EmptyState(
                  title: selectedStatus == null
                      ? 'You have not reported anything yet'
                      : 'No ${selectedStatus.label.toLowerCase()} reports',
                  message: selectedStatus == null
                      ? 'Use the + button to report an issue on campus.'
                      : 'Reports with this status will appear here.',
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    IncidentCard(
                      incident: list[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              IncidentDetailScreen(incidentId: list[i].id),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            ),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(myIncidentsProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.initials,
  });

  final String name;
  final String email;
  final String department;
  final UserRole role;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: role == UserRole.staff
                            ? AppColors.resolvedBg
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: role == UserRole.staff
                              ? AppColors.resolved
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (department.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _MetaRow(icon: Icons.school_outlined, text: department),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _MetaRow(icon: Icons.mail_outline_rounded, text: email),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
