import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/incident.dart';
import '../models/incident_status.dart';

/// All Firestore + Storage access for incidents lives here so the UI and
/// providers never talk to Firebase directly.
class IncidentRepository {
  IncidentRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  /// Every report on campus, newest first. Real-time.
  Stream<List<Incident>> watchAll() => _incidents
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Incident.fromDoc).toList());

  /// Reports created by one user. Sorted on the client so that no composite
  /// Firestore index is required.
  Stream<List<Incident>> watchByReporter(String uid) => _incidents
          .where('reporterId', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map(Incident.fromDoc).toList();
        list.sort(_newestFirst);
        return list;
      });

  Stream<Incident?> watchOne(String id) => _incidents
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Incident.fromDoc(doc) : null);

  /// Uploads a photo to `incidents/{uid}/{timestamp}.{ext}` and returns its
  /// download URL.
  Future<String> uploadPhoto({required String uid, required File file}) async {
    final rawExt = file.path.split('.').last.toLowerCase();
    const allowed = {'jpg', 'jpeg', 'png', 'webp', 'heic'};
    final ext = allowed.contains(rawExt) ? rawExt : 'jpg';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref().child('incidents/$uid/$fileName');
    await ref.putFile(file, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  /// Uploads the optional photo first, then writes the document.
  /// Returns the new document id.
  Future<String> create({required Incident draft, File? photo}) async {
    String? photoUrl;
    if (photo != null) {
      photoUrl = await uploadPhoto(uid: draft.reporterId, file: photo);
    }
    final doc = await _incidents.add(draft.copyWith(photoUrl: photoUrl).toMap());
    return doc.id;
  }

  /// Staff-only (enforced by security rules). Appends to the audit trail.
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String byId,
    required String byName,
    String? note,
  }) {
    final change = StatusChange(
      status: status,
      at: DateTime.now(),
      byId: byId,
      byName: byName,
      note: note,
    );
    return _incidents.doc(id).update({
      'status': status.id,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([change.toMap()]),
    });
  }

  /// Reporter-only while the report is still 'submitted' (see rules).
  Future<void> delete(String id) => _incidents.doc(id).delete();

  static int _newestFirst(Incident a, Incident b) {
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return -1; // pending server timestamp = newest
    if (bTime == null) return 1;
    return bTime.compareTo(aTime);
  }
}
