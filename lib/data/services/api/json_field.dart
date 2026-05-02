/// Helpers used by `*ApiModel.fromJson` factories to read JSON fields with
/// **clear failure messages** that name the offending key.
///
/// Without this, `json['id'] as int` on a missing field throws a generic
/// `TypeError` that doesn't reveal WHICH field broke. With these helpers the
/// failure carries the key name, so the UI can surface
/// "Missing/invalid field: email" instead of "Unexpected data shape".
library;

/// Reads a required field. Throws [FieldShapeException] if the key is missing
/// or the value has the wrong type.
T jsonRequired<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is T) return value;
  throw FieldShapeException(key: key, expected: T, actual: value?.runtimeType);
}

/// Reads an optional field. Returns `null` if the key is absent or the value
/// has the wrong type — never throws. Pair with `?? <default>` at the call
/// site when a sensible default exists.
T? jsonOptional<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is T ? value : null;
}

/// Thrown by [jsonRequired] when a required JSON field is missing or has an
/// unexpected type. Carries the field name so the UI can produce an
/// actionable error instead of a generic message.
///
/// Implements [Exception] (not `Error`) so it flows through the repository's
/// `try/catch` and `errorMessageFor` cleanly.
class FieldShapeException implements Exception {
  const FieldShapeException({
    required this.key,
    required this.expected,
    this.actual,
  });

  final String key;
  final Type expected;
  final Type? actual;

  @override
  String toString() =>
      'FieldShapeException: field "$key" expected $expected '
      'but got ${actual ?? 'null'}';
}
