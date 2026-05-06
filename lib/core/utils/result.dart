sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}

extension ResultX<T> on Result<T> {
  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get value => (this as Ok<T>).value;
  String get error => (this as Err<T>).message;

  R fold<R>(R Function(T) onOk, R Function(String) onErr) {
    return switch (this) {
      Ok<T> ok => onOk(ok.value),
      Err<T> err => onErr(err.message),
    };
  }
}
