import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/status_style.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/incident_providers.dart';
import '../auth/auth_scaffold.dart';

/// Staff-only bottom sheet for moving a report to a new status.
class StatusUpdateSheet extends ConsumerStatefulWidget {
  const StatusUpdateSheet({super.key, required this.incident});

  final Incident incident;

  @override
  ConsumerState<StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends ConsumerState<StatusUpdateSheet> {
  late IncidentStatus _selected;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to the next step in the workflow.
    final next = widget.incident.status.index + 1;
    _selected = next < IncidentStatus.values.length
        ? IncidentStatus.values[next]
        : widget.incident.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ok = await ref.read(statusUpdateControllerProvider.notifier).update(
          incidentId: widget.incident.id,
          status: _selected,
          note: _noteController.text,
        );
    if (!mounted) return;

    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_selected.label}.'),
          backgroundColor: AppColors.resolved,
        ),
      );
    } else {
      final error = ref.read(statusUpdateControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Update failed: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(statusUpdateControllerProvider).isLoading;
    final unchanged = _selected == widget.incident.status;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Update Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            widget.incident.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          const FieldLabel('New status'),
          Wrap(
            spacing: 8,
            children: [
              for (final status in IncidentStatus.values)
                ChoiceChip(
                  label: Text(status.label),
                  avatar: Icon(
                    status.icon,
                    size: 16,
                    color: _selected == status ? Colors.white : status.color,
                  ),
                  selected: _selected == status,
                  showCheckmark: false,
                  selectedColor: status.color,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selected == status
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  onSelected: saving
                      ? null
                      : (_) => setState(() => _selected = status),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const FieldLabel('Note for the reporter', optional: true),
          TextField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Plumber scheduled for tomorrow morning.',
            ),
          ),
          const SizedBox(height: 8),
          LoadingButton(
            label: unchanged ? 'Choose a different status' : 'Save Update',
            loading: saving,
            onPressed: unchanged ? null : _save,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}
