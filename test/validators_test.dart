import 'package:campus_incident_reporter/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('accepts a valid address', () {
      expect(Validators.email('k.uwambaye@alustudent.com'), isNull);
    });

    test('rejects empty and malformed input', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires at least 6 characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('must match the original', () {
      expect(Validators.confirmPassword('abcdef', 'abcdef'), isNull);
      expect(Validators.confirmPassword('abcdeX', 'abcdef'),
          'Passwords do not match');
    });
  });

  group('Validators.lengthRange', () {
    test('enforces min and max after trimming', () {
      expect(
        Validators.lengthRange('  hi ', min: 5, max: 80, field: 'Title'),
        'Title must be at least 5 characters',
      );
      expect(
        Validators.lengthRange('Broken tap', min: 5, max: 80, field: 'Title'),
        isNull,
      );
      expect(
        Validators.lengthRange('x' * 81, min: 5, max: 80, field: 'Title'),
        'Title must be at most 80 characters',
      );
    });
  });
}
