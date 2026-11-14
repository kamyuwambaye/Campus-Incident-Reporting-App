import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/incident_stats.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

/// The four summary tiles from the design (or three when [showSubmitted] is
/// false, as on the profile screen).
class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.stats,
    this.totalLabel = 'My Reports',
    this.showSubmitted = true,
  });

  final IncidentStats stats;
  final String totalLabel;
  final bool showSubmitted;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      StatCard(
        label: totalLabel,
        value: stats.total,
        icon: Icons.description_outlined,
        color: AppColors.primary,
        background: AppColors.primaryLight,
      ),
      StatCard(
        label: 'In Progress',
        value: stats.inProgress,
        icon: Icons.schedule_rounded,
        color: AppColors.inProgress,
        background: AppColors.inProgressBg,
      ),
      StatCard(
        label: 'Resolved',
        value: stats.resolved,
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.resolved,
        background: AppColors.resolvedBg,
      ),
      if (showSubmitted)
        StatCard(
          label: 'Submitted',
          value: stats.submitted,
          icon: Icons.error_outline_rounded,
          color: AppColors.danger,
          background: AppColors.dangerBg,
        ),
    ];

    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}
