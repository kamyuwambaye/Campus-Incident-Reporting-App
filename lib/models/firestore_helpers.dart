import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Firestore value (Timestamp or DateTime) into a DateTime.
DateTime? toDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

/// Converts a DateTime into what Firestore should store. `null` becomes a
/// server-side timestamp so clocks on devices never matter.
Object dateToFirestore(DateTime? value) =>
    value == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(value);
