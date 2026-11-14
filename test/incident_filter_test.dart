import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_filter.dart';
import 'package:campus_incident_reporter/models/incident_stats.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:flutter_test/flutter_test.dart';

Incident _incident({
  required String id,
  required String title,
  IncidentCategory category = IncidentCategory.facilities,
  IncidentStatus status = IncidentStatus.submitted,
  String location = 'Block B',
  String reporter = 'Amina Hassan',
}) =>
    Incident(
      id: id,
      title: title,
      description: 'Some description text that is long enough.',
      category: category,
      location: location,
      status: status,
      reporterId: 'uid-$id',
      reporterName: reporter,
    );

void main() {
  final incidents = [
    _incident(
      id: '1',
      title: 'Water shortage',
      category: IncidentCategory.water,
      location: 'Student Residence',
    ),
    _incident(
      id: '2',
      title: 'Broken classroom projector',
      status: IncidentStatus.inProgress,
    ),
    _incident(
      id: '3',
      title: 'Overflowing bin',
      category: IncidentCategory.sanitation,
      status: IncidentStatus.resolved,
      location: 'Cafeteria',
      reporter: 'John Doe',
    ),
  ];

  group('IncidentFilter', () {
    test('empty filter returns everything and is inactive', () {
      const filter = IncidentFilter();
      expect(filter.isActive, isFalse);
      expect(filter.apply(incidents).length, 3);
    });

    test('filters by status', () {
      final result = const IncidentFilter(status: IncidentStatus.resolved)
          .apply(incidents);
      expect(result.map((i) => i.id), ['3']);
    });

    test('filters by category', () {
      final result = const IncidentFilter(category: IncidentCategory.water)
          .apply(incidents);
      expect(result.map((i) => i.id), ['1']);
    });

    test('search is case-insensitive across title, location and reporter', () {
      expect(const IncidentFilter(query: 'PROJECTOR').apply(incidents).length,
          1);
      expect(const IncidentFilter(query: 'cafeteria').apply(incidents).length,
          1);
      expect(const IncidentFilter(query: 'john').apply(incidents).length, 1);
      expect(const IncidentFilter(query: 'xyz').apply(incidents), isEmpty);
    });

    test('copyWith can clear a nullable field', () {
      const filter = IncidentFilter(category: IncidentCategory.water);
      expect(filter.copyWith(category: null).category, isNull);
      expect(filter.copyWith(query: 'a').category, IncidentCategory.water);
    });
  });

  group('IncidentStats', () {
    test('counts by status', () {
      final stats = IncidentStats.fromList(incidents);
      expect(stats.total, 3);
      expect(stats.submitted, 1);
      expect(stats.inProgress, 1);
      expect(stats.resolved, 1);
    });
  });
}
