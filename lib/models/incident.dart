import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_helpers.dart';
import 'incident_category.dart';
import 'incident_status.dart';

/// One entry in an incident's audit trail (`statusHistory` array).
class StatusChange {
  const StatusChange({
    required this.status,
    required this.at,
    required this.byName,
    this.byId = '',
    this.note,
  });

  final IncidentStatus status;
  final DateTime? at;
  final String byName;
  final String byId;
  final String? note;

  bool get hasNote => note != null && note!.trim().isNotEmpty;

  factory StatusChange.fromMap(Map<String, dynamic> map) => StatusChange(
        status: IncidentStatus.fromId(map['status'] as String?),
        at: toDateTime(map['at']),
        byName: (map['byName'] as String?) ?? '',
        byId: (map['byId'] as String?) ?? '',
        note: map['note'] as String?,
      );

  /// Array elements cannot hold `FieldValue.serverTimestamp()`, so the
  /// device clock is used here; the document-level `updatedAt` stays
  /// server-authoritative.
  Map<String, dynamic> toMap() => {
        'status': status.id,
        'at': Timestamp.fromDate(at ?? DateTime.now()),
        'byName': byName,
        'byId': byId,
        if (hasNote) 'note': note!.trim(),
      };
}

/// Document stored at `incidents/{incidentId}`.
class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.statusHistory = const [],
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<StatusChange> statusHistory;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// When the report first reached [target], or `null` if it never did.
  DateTime? dateFor(IncidentStatus target) {
    for (final change in statusHistory) {
      if (change.status == target) return change.at;
    }
    return null;
  }

  /// Case-insensitive free-text match used by the browse screen.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q) ||
        reporterName.toLowerCase().contains(q) ||
        category.label.toLowerCase().contains(q);
  }

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Incident.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    final history = <StatusChange>[];
    final rawHistory = data['statusHistory'];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map) {
          history.add(StatusChange.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return Incident(
      id: id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: IncidentCategory.fromId(data['category'] as String?),
      location: (data['location'] as String?) ?? '',
      status: IncidentStatus.fromId(data['status'] as String?),
      reporterId: (data['reporterId'] as String?) ?? '',
      reporterName: (data['reporterName'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: toDateTime(data['createdAt']),
      updatedAt: toDateTime(data['updatedAt']),
      statusHistory: history,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category.id,
        'location': location,
        'status': status.id,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'photoUrl': photoUrl,
        'createdAt': dateToFirestore(createdAt),
        'updatedAt': dateToFirestore(updatedAt),
        'statusHistory': statusHistory.map((c) => c.toMap()).toList(),
      };

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    IncidentCategory? category,
    String? location,
    IncidentStatus? status,
    String? reporterId,
    String? reporterName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<StatusChange>? statusHistory,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}
