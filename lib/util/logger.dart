import 'package:fimber/fimber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class Logger {
  final String tag;

  const Logger(this.tag);

  factory Logger.withTag(String tag) => LoggerImpl(tag);

  void v(String message, {Object? ex, StackTrace? stacktrace});

  void d(String message, {Object? ex, StackTrace? stacktrace});

  void i(String message, {Object? ex, StackTrace? stacktrace});

  void w(String message, {Object? ex, StackTrace? stacktrace});

  void e(String message, {Object? ex, StackTrace? stacktrace});
}

class LoggerImpl extends Logger {
  LoggerImpl(super.tag);

  @override
  void v(String message, {Object? ex, StackTrace? stacktrace}) {
    _log("V", tag, message, ex: ex, stacktrace: stacktrace);
  }

  @override
  void d(String message, {Object? ex, StackTrace? stacktrace}) {
    _log("D", tag, message, ex: ex, stacktrace: stacktrace);
  }

  @override
  void i(String message, {Object? ex, StackTrace? stacktrace}) {
    _log("I", tag, message, ex: ex, stacktrace: stacktrace);
  }

  @override
  void w(String message, {Object? ex, StackTrace? stacktrace}) {
    _log("W", tag, message, ex: ex, stacktrace: stacktrace);
  }

  @override
  void e(String message, {Object? ex, StackTrace? stacktrace}) {
    _log("E", tag, message, ex: ex, stacktrace: stacktrace);
  }

  void _log(
      String level,
      String tag,
      String message, {
        Object? ex,
        StackTrace? stacktrace,
      }) {
    Fimber.log(level, message, tag: tag, ex: ex, stacktrace: stacktrace);
    _logToSentry(level, tag, message, ex: ex, stacktrace: stacktrace);
  }

  // Sentry's static API no-ops when SentryFlutter.init was never called (the
  // quizzy flavor), so this stays flavor-agnostic. Only 'i' and above are
  // forwarded — 'v'/'d' stay Fimber-only.
  void _logToSentry(
      String level,
      String tag,
      String message, {
        Object? ex,
        StackTrace? stacktrace,
      }) {
    final attributes = {'tag': SentryAttribute.string(tag)};
    switch (level) {
      case 'I':
        Sentry.logger.info(message, attributes: attributes);
      case 'W':
        Sentry.logger.warn(message, attributes: attributes);
      case 'E':
        Sentry.logger.error(message, attributes: attributes);
        if (ex != null) {
          Sentry.captureException(ex, stackTrace: stacktrace);
        }
    }
  }
}
