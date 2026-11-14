/// Lifecycle of a report. Declaration order is the workflow order, which the
/// status timeline relies on.
enum IncidentStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  const IncidentStatus(this.id, this.label);

  final String id;
  final String label;

  bool get isFinal => this == IncidentStatus.resolved;

  static IncidentStatus fromId(String? id) {
    for (final status in values) {
      if (status.id == id) return status;
    }
    return IncidentStatus.submitted;
  }
}
