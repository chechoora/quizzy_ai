import 'package:fimber/fimber.dart';

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
  }
}
