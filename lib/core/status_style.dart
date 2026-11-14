import 'package:flutter/material.dart';

import '../models/incident_status.dart';
import 'theme.dart';

/// Presentation details for each status, kept out of the pure model.
extension IncidentStatusStyle on IncidentStatus {
  Color get color => switch (this) {
        IncidentStatus.submitted => AppColors.submitted,
        IncidentStatus.inProgress => AppColors.inProgress,
        IncidentStatus.resolved => AppColors.resolved,
      };

  Color get backgroundColor => switch (this) {
        IncidentStatus.submitted => AppColors.submittedBg,
        IncidentStatus.inProgress => AppColors.inProgressBg,
        IncidentStatus.resolved => AppColors.resolvedBg,
      };

  IconData get icon => switch (this) {
        IncidentStatus.submitted => Icons.send_rounded,
        IncidentStatus.inProgress => Icons.schedule_rounded,
        IncidentStatus.resolved => Icons.check_rounded,
      };
}
