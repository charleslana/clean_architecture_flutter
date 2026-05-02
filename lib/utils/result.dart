/// A sealed [Result] type used by the data layer to communicate success or
/// failure to the UI layer without leaking exceptions across boundaries.
///
/// Following the Flutter architecture guide:
/// https://docs.flutter.dev/app-architecture/design-patterns/result
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(Exception error) = Error<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.error);
  final Exception error;
}
