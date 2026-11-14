import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_filter.dart';
import '../models/incident_stats.dart';
import '../models/incident_status.dart';
import '../services/auth_service.dart';
import '../services/incident_repository.dart';
import 'auth_providers.dart';
import 'firebase_providers.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>(
  (ref) => IncidentRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  ),
);

// ---------------------------------------------------------------------------
// Read side: real-time streams
// ---------------------------------------------------------------------------

/// Every report on campus (used by the browse screen and staff dashboard).
final allIncidentsProvider = StreamProvider<List<Incident>>(
  (ref) => ref.watch(incidentRepositoryProvider).watchAll(),
);

/// Only the reports created by the signed-in user.
final myIncidentsProvider = StreamProvider<List<Incident>>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  if (uid == null) return Stream.value(const <Incident>[]);
  return ref.watch(incidentRepositoryProvider).watchByReporter(uid);
});

/// A single report, kept live so staff updates appear instantly.
final incidentProvider = StreamProvider.family<Incident?, String>(
  (ref, id) => ref.watch(incidentRepositoryProvider).watchOne(id),
);

/// Dashboard counts. Staff see campus-wide numbers, students their own.
final dashboardIncidentsProvider = Provider<AsyncValue<List<Incident>>>((ref) {
  final isStaff = ref.watch(isStaffProvider);
  return ref.watch(isStaff ? allIncidentsProvider : myIncidentsProvider);
});

final dashboardStatsProvider = Provider<IncidentStats>((ref) {
  final incidents = ref.watch(dashboardIncidentsProvider).asData?.value;
  return IncidentStats.fromList(incidents ?? const []);
});

final myStatsProvider = Provider<IncidentStats>((ref) {
  final incidents = ref.watch(myIncidentsProvider).asData?.value;
  return IncidentStats.fromList(incidents ?? const []);
});

// ---------------------------------------------------------------------------
// Search & filter state (browse screen)
// ---------------------------------------------------------------------------

class IncidentFilterNotifier extends Notifier<IncidentFilter> {
  @override
  IncidentFilter build() => const IncidentFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setCategory(IncidentCategory? category) =>
      state = state.copyWith(category: category);

  void setStatus(IncidentStatus? status) =>
      state = state.copyWith(status: status);

  void clear() => state = const IncidentFilter();
}

final incidentFilterProvider =
    NotifierProvider<IncidentFilterNotifier, IncidentFilter>(
  IncidentFilterNotifier.new,
);

/// Derived: all incidents with the current filter applied.
final filteredIncidentsProvider = Provider<AsyncValue<List<Incident>>>((ref) {
  final filter = ref.watch(incidentFilterProvider);
  return ref.watch(allIncidentsProvider).whenData(filter.apply);
});

/// Status chip selection on the "My Reports" screen.
class MyReportsStatusNotifier extends Notifier<IncidentStatus?> {
  @override
  IncidentStatus? build() => null;

  void select(IncidentStatus? status) => state = status;
}

final myReportsStatusProvider =
    NotifierProvider<MyReportsStatusNotifier, IncidentStatus?>(
  MyReportsStatusNotifier.new,
);

final filteredMyIncidentsProvider = Provider<AsyncValue<List<Incident>>>((ref) {
  final status = ref.watch(myReportsStatusProvider);
  return ref.watch(myIncidentsProvider).whenData(
        (list) => status == null
            ? list
            : list.where((i) => i.status == status).toList(),
      );
});

// ---------------------------------------------------------------------------
// Write side: controllers with loading/error state
// ---------------------------------------------------------------------------

/// Handles the "Submit Report" action, including the photo upload.
class SubmitReportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns the new incident id, or `null` on failure (state holds the error).
  Future<String?> submit({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    File? photo,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) {
      state = AsyncError(
        const AuthFailure('You must be signed in to submit a report.'),
        StackTrace.current,
      );
      return null;
    }
    final profile = ref.read(currentUserProvider).asData?.value;
    final reporterName = profile?.name.isNotEmpty == true
        ? profile!.name
        : (user.displayName ?? 'Student');

    state = const AsyncLoading();
    String? newId;
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      final draft = Incident(
        id: '',
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        status: IncidentStatus.submitted,
        reporterId: user.uid,
        reporterName: reporterName,
        statusHistory: [
          StatusChange(
            status: IncidentStatus.submitted,
            at: now,
            byId: user.uid,
            byName: reporterName,
          ),
        ],
      );
      newId = await ref
          .read(incidentRepositoryProvider)
          .create(draft: draft, photo: photo);
    });
    return state.hasError ? null : newId;
  }
}

final submitReportControllerProvider =
    AsyncNotifierProvider<SubmitReportController, void>(
  SubmitReportController.new,
);

/// Staff action: move a report to a new status with an optional note.
class StatusUpdateController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> update({
    required String incidentId,
    required IncidentStatus status,
    String? note,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    final profile = ref.read(currentUserProvider).asData?.value;
    if (user == null || profile == null || !profile.isStaff) {
      state = AsyncError(
        const AuthFailure('Only authorised staff can update a report.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(incidentRepositoryProvider).updateStatus(
            id: incidentId,
            status: status,
            byId: user.uid,
            byName: profile.name,
            note: note,
          ),
    );
    return !state.hasError;
  }
}

final statusUpdateControllerProvider =
    AsyncNotifierProvider<StatusUpdateController, void>(
  StatusUpdateController.new,
);
