import 'package:campus_incident_reporter/core/utils/time_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 16, 12, 0);

  test('null date reads as Just now (pending server timestamp)', () {
    expect(timeAgo(null, now: now), 'Just now');
  });

  test('relative buckets', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 30)), now: now),
        'Just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago');
    expect(timeAgo(now.subtract(const Duration(hours: 1)), now: now),
        '1 hour ago');
    expect(timeAgo(now.subtract(const Duration(hours: 2)), now: now),
        '2 hours ago');
    expect(timeAgo(now.subtract(const Duration(days: 1)), now: now),
        '1 day ago');
    expect(timeAgo(now.subtract(const Duration(days: 3)), now: now),
        '3 days ago');
    expect(timeAgo(now.subtract(const Duration(days: 14)), now: now),
        '2 weeks ago');
  });

  test('older than a month falls back to an absolute date', () {
    expect(timeAgo(DateTime(2026, 1, 5), now: now), 'Jan 5, 2026');
  });

  test('absolute formatters', () {
    expect(formatDate(null), 'Pending');
    expect(formatDateTime(DateTime(2026, 10, 15, 10, 24)),
        'Oct 15, 2026, 10:24 AM');
  });
}
