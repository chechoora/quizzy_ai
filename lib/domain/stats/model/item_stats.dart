import 'package:equatable/equatable.dart';

/// A week/month/year triple of the same value type. Reused for every stat
/// that's tracked per rolling period (accuracy, attempts, bestStreak).
class PeriodStats<T> extends Equatable {
  final T week;
  final T month;
  final T year;

  const PeriodStats({
    required this.week,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [week, month, year];
}

/// Quizzy-ai-pro backend play stats for a deck or a card. Only ever
/// populated for rows synced from the backend (`enableRemoteSync` flavors);
/// local-only rows simply never have one.
class ItemStats extends Equatable {
  /// Null per-period entries mean no attempts were recorded in that period.
  final PeriodStats<double?> accuracy;
  final PeriodStats<int> attempts;
  final PeriodStats<int> bestStreak;
  final DateTime? lastPlayedAt;

  const ItemStats({
    required this.accuracy,
    required this.attempts,
    required this.bestStreak,
    this.lastPlayedAt,
  });

  @override
  List<Object?> get props => [accuracy, attempts, bestStreak, lastPlayedAt];
}
