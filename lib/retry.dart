import 'dart:async';

Future<T> retry<T>(
  FutureOr<T> Function() fn, {
  FutureOr<bool> Function(Exception)? retryIf,
  FutureOr<void> Function(Exception)? onRetry,
  int maxAttempts = 5,
}) async {
  var attempt = 0;
// ignore: literal_only_boolean_expressions
  while (true) {
    attempt++; // first invocation is the first attempt
    try {
      return await fn();
    } on Exception catch (e) {
      if (attempt >= maxAttempts || (retryIf != null && !(await retryIf(e)))) {
        rethrow;
      }
      if (onRetry != null) {
        await onRetry(e);
      }
    }

// Sleep for a delay
    await Future.delayed(delay(attempt));
  }
}

/// Delay after [attempt] number of attempts.
///
/// This is computed as `pow(2, attempt) * delayFactor`, then is multiplied by
/// between `-randomizationFactor` and `randomizationFactor` at random.
Duration delay(int attempt) {
  return attempt == 0
      ? 1.seconds
      : attempt == 1
          ? const Duration(seconds: 2)
          : const Duration(seconds: 3);
  // switch (attempt) {
  //   0 => 1.seconds,
  //   1 => const Duration(seconds: 2),
  //   _ => const Duration(seconds: 3)
  // };
}

extension intExt on int {
  get seconds => Duration(seconds: this);
}
