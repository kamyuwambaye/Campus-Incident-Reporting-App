/// App-wide constants shared by the UI, validators and Firestore rules.
class AppConstants {
  AppConstants._();

  static const String appName = 'Campus Incident Reporter';

  /// Locations offered in the report form. 'Other' lets the user type freely.
  static const List<String> campusLocations = [
    'Block A',
    'Block B',
    'Block C',
    'Student Residence',
    'Cafeteria',
    'Library',
    'Computer Lab',
    'Admin Building',
    'Sports Field',
    'Parking Area',
    'Other',
  ];

  // These limits are mirrored in firestore.rules.
  static const int titleMinLength = 5;
  static const int titleMaxLength = 80;
  static const int descriptionMinLength = 20;
  static const int descriptionMaxLength = 1000;

  /// Mirrored in storage.rules.
  static const int maxPhotoBytes = 5 * 1024 * 1024;
}
