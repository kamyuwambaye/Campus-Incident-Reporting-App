import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/status_style.dart';
import '../../core/theme.dart';
import '../../core/utils/time_format.dart';
import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/incident_thumbnail.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import 'status_update_sheet.dart';

/// Live view of one report. Staff get an "Update Status" action; the
/// reporter can withdraw a report that has not been picked up yet.
class IncidentDetailScreen extends ConsumerWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentProvider(incidentId));
    final isStaff = ref.watch(isStaffProvider);
    final uid = ref.watch(authStateProvider).asData?.value?.uid;

    return incidentAsync.when(
      data: (incident) {
        if (incident == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Incident Details')),
            body: const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Report not found',
              message: 'This report may have been withdrawn.',
            ),
          );
        }
        return _DetailView(
          incident: incident,
          isStaff: isStaff,
          isOwner: uid != null && uid == incident.reporterId,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const LoadingView(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(incidentProvider(incidentId)),
        ),
      ),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.incident,
    required this.isStaff,
    required this.isOwner,
  });

  final Incident incident;
  final bool isStaff;
  final bool isOwner;

  bool get _canWithdraw =>
      isOwner && incident.status == IncidentStatus.submitted;

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw report?'),
        content: const Text(
          'This will permanently remove your report. You can only withdraw '
          'a report before staff start working on it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(incidentRepositoryProvider).delete(incident.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Report withdrawn.')),
      );
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not withdraw the report: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openStatusSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatusUpdateSheet(incident: incident),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = incident.statusHistory.where((c) => c.hasNote).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (_canWithdraw)
            PopupMenuButton<String>(
              onSelected: (_) => _withdraw(context, ref),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'withdraw',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          color: AppColors.danger, size: 20),
                      SizedBox(width: 8),
                      Text('Withdraw report'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IncidentThumbnail(incident: incident, size: 76, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StatusChip(status: incident.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: 'Submitted on ${formatDateTime(incident.createdAt)}',
          ),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            text: 'Reported by ${incident.reporterName}',
          ),
          _InfoRow(
            icon: incident.category.icon,
            text: 'Category: ${incident.category.label}',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Status Timeline'),
          const SizedBox(height: 14),
          StatusTimeline(incident: incident),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Description'),
          const SizedBox(height: 8),
          Text(
            incident.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          if (incident.hasPhoto) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Attached Photo'),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                incident.photoUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        height: 220,
                        color: AppColors.primaryLight,
                        child: const LoadingView(),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Text('Photo could not be loaded'),
                  ),
                ),
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Staff Updates'),
            const SizedBox(height: 10),
            for (final change in notes.reversed) _NoteCard(change: change),
          ],
        ],
      ),
      bottomNavigationBar: isStaff
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton.icon(
                  onPressed: incident.status.isFinal
                      ? null
                      : () => _openStatusSheet(context),
                  icon: const Icon(Icons.update_rounded),
                  label: Text(
                    incident.status.isFinal
                        ? 'Report Resolved'
                        : 'Update Status',
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.change});

  final StatusChange change;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(change.status.icon, size: 16, color: change.status.color),
              const SizedBox(width: 6),
              Text(
                change.status.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: change.status.color,
                ),
              ),
              const Spacer(),
              Text(
                formatShortDateTime(change.at),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            change.note ?? '',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${change.byName}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
