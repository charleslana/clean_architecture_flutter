library;

T jsonRequired<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is T) return value;
  throw FieldShapeException(key: key, expected: T, actual: value?.runtimeType);
}

T? jsonOptional<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is T ? value : null;
}

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
