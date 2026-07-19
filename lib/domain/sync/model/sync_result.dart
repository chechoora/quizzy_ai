import 'package:equatable/equatable.dart';

/// Outcome of one push cycle ([DeckCardSyncService.pushLocalChanges]).
class SyncPushResult extends Equatable {
  final int decksPushed;
  final int cardsPushed;
  final int deckTombstonesPurged;
  final int cardTombstonesPurged;
  final int failures;

  const SyncPushResult({
    this.decksPushed = 0,
    this.cardsPushed = 0,
    this.deckTombstonesPurged = 0,
    this.cardTombstonesPurged = 0,
    this.failures = 0,
  });

  SyncPushResult copyWith({
    int? decksPushed,
    int? cardsPushed,
    int? deckTombstonesPurged,
    int? cardTombstonesPurged,
    int? failures,
  }) {
    return SyncPushResult(
      decksPushed: decksPushed ?? this.decksPushed,
      cardsPushed: cardsPushed ?? this.cardsPushed,
      deckTombstonesPurged: deckTombstonesPurged ?? this.deckTombstonesPurged,
      cardTombstonesPurged: cardTombstonesPurged ?? this.cardTombstonesPurged,
      failures: failures ?? this.failures,
    );
  }

  @override
  List<Object?> get props => [
        decksPushed,
        cardsPushed,
        deckTombstonesPurged,
        cardTombstonesPurged,
        failures,
      ];

  @override
  String toString() =>
      'SyncPushResult(decksPushed: $decksPushed, cardsPushed: $cardsPushed, '
      'deckTombstonesPurged: $deckTombstonesPurged, '
      'cardTombstonesPurged: $cardTombstonesPurged, failures: $failures)';
}

/// Outcome of one pull cycle ([DeckCardSyncService.pullRemoteChanges]).
class SyncPullResult extends Equatable {
  final int decksUpserted;
  final int cardsUpserted;
  final int decksDeletedLocally;
  final int cardsDeletedLocally;
  final int failures;

  const SyncPullResult({
    this.decksUpserted = 0,
    this.cardsUpserted = 0,
    this.decksDeletedLocally = 0,
    this.cardsDeletedLocally = 0,
    this.failures = 0,
  });

  SyncPullResult copyWith({
    int? decksUpserted,
    int? cardsUpserted,
    int? decksDeletedLocally,
    int? cardsDeletedLocally,
    int? failures,
  }) {
    return SyncPullResult(
      decksUpserted: decksUpserted ?? this.decksUpserted,
      cardsUpserted: cardsUpserted ?? this.cardsUpserted,
      decksDeletedLocally: decksDeletedLocally ?? this.decksDeletedLocally,
      cardsDeletedLocally: cardsDeletedLocally ?? this.cardsDeletedLocally,
      failures: failures ?? this.failures,
    );
  }

  @override
  List<Object?> get props => [
        decksUpserted,
        cardsUpserted,
        decksDeletedLocally,
        cardsDeletedLocally,
        failures,
      ];

  @override
  String toString() =>
      'SyncPullResult(decksUpserted: $decksUpserted, cardsUpserted: '
      '$cardsUpserted, decksDeletedLocally: $decksDeletedLocally, '
      'cardsDeletedLocally: $cardsDeletedLocally, failures: $failures)';
}

/// Outcome of a full push-then-pull cycle ([DeckCardSyncService.runFullSync]).
class SyncRunResult extends Equatable {
  final SyncPushResult push;
  final SyncPullResult pull;

  const SyncRunResult({required this.push, required this.pull});

  @override
  List<Object?> get props => [push, pull];

  @override
  String toString() => 'SyncRunResult(push: $push, pull: $pull)';
}
