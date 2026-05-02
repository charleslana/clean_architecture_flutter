import 'package:clean_architecture_flutter/data/services/api/json_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('jsonRequired', () {
    test('returns the value when present and correctly typed', () {
      final json = <String, dynamic>{'id': 42, 'name': 'Alice'};

      expect(jsonRequired<int>(json, 'id'), 42);
      expect(jsonRequired<String>(json, 'name'), 'Alice');
    });

    test('throws FieldShapeException with the key when MISSING', () {
      final json = <String, dynamic>{'id': 42};

      expect(
        () => jsonRequired<String>(json, 'name'),
        throwsA(
          isA<FieldShapeException>()
              .having((e) => e.key, 'key', 'name')
              .having((e) => e.expected, 'expected', String)
              .having((e) => e.actual, 'actual', isNull),
        ),
      );
    });

    test('throws FieldShapeException with the key when WRONG TYPE', () {
      final json = <String, dynamic>{'id': 'not-an-int'};

      expect(
        () => jsonRequired<int>(json, 'id'),
        throwsA(
          isA<FieldShapeException>()
              .having((e) => e.key, 'key', 'id')
              .having((e) => e.expected, 'expected', int)
              .having((e) => e.actual, 'actual', String),
        ),
      );
    });
  });

  group('jsonOptional', () {
    test('returns the value when present and correctly typed', () {
      final json = <String, dynamic>{'phone': '555-0000'};

      expect(jsonOptional<String>(json, 'phone'), '555-0000');
    });

    test('returns null when MISSING (does NOT throw)', () {
      final json = <String, dynamic>{};

      expect(jsonOptional<String>(json, 'phone'), isNull);
    });

    test('returns null when WRONG TYPE (does NOT throw)', () {
      final json = <String, dynamic>{'phone': 12345};

      expect(jsonOptional<String>(json, 'phone'), isNull);
    });
  });
}
