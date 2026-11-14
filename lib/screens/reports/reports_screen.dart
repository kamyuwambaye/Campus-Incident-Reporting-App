import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/state_views.dart';
import '../detail/incident_detail_screen.dart';

/// Browse every report on campus with free-text search plus status and
/// category filters. Staff use this screen to find reports to update.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the text field in sync when the filter is cleared via "Clear".
    ref.listen(incidentFilterProvider, (_, next) {
      if (next.query.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    final filter = ref.watch(incidentFilterProvider);
    final notifier = ref.read(incidentFilterProvider.notifier);
    final results = ref.watch(filteredIncidentsProvider);
    final isStaff = ref.watch(isStaffProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isStaff ? 'All Reports' : 'Browse Reports'),
        actions: [
          if (filter.isActive)
            TextButton(
              onPressed: notifier.clear,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: notifier.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by title, location or reporter',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          FilterChipRow<IncidentStatus>(
            options: IncidentStatus.values,
            selected: filter.status,
            labelOf: (s) => s.label,
            onSelected: notifier.setStatus,
          ),
          const SizedBox(height: 8),
          FilterChipRow<IncidentCategory>(
            options: IncidentCategory.values,
            selected: filter.category,
            labelOf: (c) => c.label,
            allLabel: 'All categories',
            onSelected: notifier.setCategory,
          ),
          if (isStaff)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Staff mode: open a report to review it and update '
                        'its status.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: results.when(
              data: (incidents) {
                if (incidents.isEmpty) {
                  return EmptyState(
                    icon: filter.isActive
                        ? Icons.search_off_rounded
                        : Icons.inbox_rounded,
                    title: filter.isActive
                        ? 'No matching reports'
                        : 'No reports yet',
                    message: filter.isActive
                        ? 'Try a different search term or clear the filters.'
                        : 'Reports submitted by students will appear here.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allIncidentsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: incidents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      return IncidentCard(
                        incident: incident,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                IncidentDetailScreen(incidentId: incident.id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(allIncidentsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
