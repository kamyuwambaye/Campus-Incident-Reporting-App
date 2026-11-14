import 'incident.dart';
import 'incident_status.dart';

/// Counts shown on the dashboard tiles.
class IncidentStats {
  const IncidentStats({
    this.total = 0,
    this.submitted = 0,
    this.inProgress = 0,
    this.resolved = 0,
  });

  final int total;
  final int submitted;
  final int inProgress;
  final int resolved;

  factory IncidentStats.fromList(List<Incident> incidents) {
    var submitted = 0;
    var inProgress = 0;
    var resolved = 0;
    for (final incident in incidents) {
      switch (incident.status) {
        case IncidentStatus.submitted:
          submitted++;
        case IncidentStatus.inProgress:
          inProgress++;
        case IncidentStatus.resolved:
          resolved++;
      }
    }
    return IncidentStats(
      total: incidents.length,
      submitted: submitted,
      inProgress: inProgress,
      resolved: resolved,
    );
  }
}
