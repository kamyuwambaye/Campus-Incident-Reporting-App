import 'incident.dart';
import 'incident_category.dart';
import 'incident_status.dart';

const Object _unset = Object();

/// Immutable search/filter criteria for the browse screen.
class IncidentFilter {
  const IncidentFilter({this.query = '', this.category, this.status});

  final String query;
  final IncidentCategory? category;
  final IncidentStatus? status;

  bool get isActive =>
      query.trim().isNotEmpty || category != null || status != null;

  IncidentFilter copyWith({
    String? query,
    Object? category = _unset,
    Object? status = _unset,
  }) {
    return IncidentFilter(
      query: query ?? this.query,
      category: identical(category, _unset)
          ? this.category
          : category as IncidentCategory?,
      status:
          identical(status, _unset) ? this.status : status as IncidentStatus?,
    );
  }

  List<Incident> apply(List<Incident> incidents) {
    return incidents.where((incident) {
      if (category != null && incident.category != category) return false;
      if (status != null && incident.status != status) return false;
      return incident.matches(query);
    }).toList();
  }
}
