import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Incident round-trips through a Firestore map', () {
    final created = DateTime(2026, 10, 15, 10, 24);
    final progressed = DateTime(2026, 10, 16, 14, 30);

    final original = Incident(
      id: 'abc',
      title: 'Water shortage',
      description: 'No water in the residence since this morning.',
      category: IncidentCategory.water,
      location: 'Student Residence',
      status: IncidentStatus.inProgress,
      reporterId: 'u1',
      reporterName: 'Amina Hassan',
      photoUrl: 'https://example.com/photo.jpg',
      createdAt: created,
      updatedAt: progressed,
      statusHistory: [
        StatusChange(
          status: IncidentStatus.submitted,
          at: created,
          byName: 'Amina Hassan',
          byId: 'u1',
        ),
        StatusChange(
          status: IncidentStatus.inProgress,
          at: progressed,
          byName: 'Facilities Staff',
          byId: 'staff1',
          note: 'Plumber dispatched',
        ),
      ],
    );

    final map = original.toMap();
    expect(map['category'], 'water');
    expect(map['status'], 'in_progress');
    expect(map['createdAt'], isA<Timestamp>());

    final restored = Incident.fromMap('abc', map);
    expect(restored.title, original.title);
    expect(restored.category, IncidentCategory.water);
    expect(restored.status, IncidentStatus.inProgress);
    expect(restored.createdAt, created);
    expect(restored.statusHistory.length, 2);
    expect(restored.statusHistory.last.note, 'Plumber dispatched');
    expect(restored.dateFor(IncidentStatus.inProgress), progressed);
    expect(restored.dateFor(IncidentStatus.resolved), isNull);
  });

  test('unknown ids fall back safely', () {
    expect(IncidentCategory.fromId('bogus'), IncidentCategory.facilities);
    expect(IncidentStatus.fromId(null), IncidentStatus.submitted);
  });

  test('fromMap tolerates missing fields', () {
    final incident = Incident.fromMap('x', const {});
    expect(incident.title, '');
    expect(incident.statusHistory, isEmpty);
    expect(incident.hasPhoto, isFalse);
  });
}
