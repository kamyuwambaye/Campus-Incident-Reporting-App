import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/widgets/incident_card.dart';
import 'package:campus_incident_reporter/widgets/status_chip.dart';
import 'package:campus_incident_reporter/widgets/status_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  const incident = Incident(
    id: '1',
    title: 'Broken classroom projector',
    description: 'The projector in room 204 does not turn on at all.',
    category: IncidentCategory.electricity,
    location: 'Block B - Room 204',
    status: IncidentStatus.inProgress,
    reporterId: 'u1',
    reporterName: 'Amina Hassan',
  );

  testWidgets('StatusChip shows the status label', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatusChip(status: IncidentStatus.resolved)),
    );
    expect(find.text('Resolved'), findsOneWidget);
  });

  testWidgets('IncidentCard renders title, location and status and taps',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(IncidentCard(incident: incident, onTap: () => tapped = true)),
    );
    expect(find.text('Broken classroom projector'), findsOneWidget);
    expect(find.text('Block B - Room 204'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);

    await tester.tap(find.byType(IncidentCard));
    expect(tapped, isTrue);
  });

  testWidgets('StatusTimeline lists all three stages', (tester) async {
    await tester.pumpWidget(_wrap(const StatusTimeline(incident: incident)));
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });
}
