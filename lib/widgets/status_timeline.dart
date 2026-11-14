import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils/time_format.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';

/// Submitted -> In Progress -> Resolved stepper with the date each stage was
/// reached.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final steps = IncidentStatus.values;
    final current = incident.status.index;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _TimelineStep(
              status: steps[i],
              date: incident.dateFor(steps[i]),
              reached: i <= current,
              lineBefore: i == 0 ? null : i <= current,
              lineAfter: i == steps.length - 1 ? null : i < current,
            ),
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.date,
    required this.reached,
    required this.lineBefore,
    required this.lineAfter,
  });

  final IncidentStatus status;
  final DateTime? date;
  final bool reached;

  /// `null` hides the connector; `true` paints it active.
  final bool? lineBefore;
  final bool? lineAfter;

  @override
  Widget build(BuildContext context) {
    Widget line(bool? active) => Expanded(
          child: Container(
            height: 2,
            color: active == null
                ? Colors.transparent
                : (active ? AppColors.primary : AppColors.border),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            line(lineBefore),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: reached ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: reached ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: Icon(
                reached ? Icons.check_rounded : Icons.add_rounded,
                size: 16,
                color: reached ? Colors.white : AppColors.textHint,
              ),
            ),
            line(lineAfter),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: reached ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          reached ? formatShortDateTime(date) : '--',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
