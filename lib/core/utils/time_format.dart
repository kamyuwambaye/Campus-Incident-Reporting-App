import 'package:intl/intl.dart';

/// Human-friendly relative time, e.g. "2 hours ago". A `null` date means the
/// server timestamp has not been confirmed yet (local pending write).
String timeAgo(DateTime? date, {DateTime? now}) {
  if (date == null) return 'Just now';
  final reference = now ?? DateTime.now();
  final diff = reference.difference(date);

  if (diff.isNegative || diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) {
    return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
  }
  if (diff.inDays < 7) {
    return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
  }
  if (diff.inDays < 30) {
    final weeks = diff.inDays ~/ 7;
    return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
  }
  return DateFormat('MMM d, yyyy').format(date);
}

String formatDate(DateTime? date) =>
    date == null ? 'Pending' : DateFormat('MMM d, yyyy').format(date);

String formatDateTime(DateTime? date) =>
    date == null ? 'Pending' : DateFormat('MMM d, yyyy, h:mm a').format(date);

String formatShortDateTime(DateTime? date) =>
    date == null ? 'Pending' : DateFormat('MMM d, h:mm a').format(date);
