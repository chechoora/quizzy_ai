import 'dart:async';
import 'dart:convert';

import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_backup_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';

/// Schedules a debounced iCloud backup of the entire deck/card library whenever
/// the local database changes. Change detection uses the Drift table watch
/// streams (decks + cards) rather than per-write callbacks.
class BackupScheduler {
  BackupScheduler({
    required this.deckRepository,
    required this.quizCardRepository,
    required this.exportService,
    required this.icloudBackupService,
    this.debounce = const Duration(seconds: 5),
  });

  /// Backup payload/schema version.
  static const String version = '1';

  final DeckRepository deckRepository;
  final QuizCardRepository quizCardRepository;
  final ExportService exportService;
  final IcloudBackupService icloudBackupService;
  final Duration debounce;

  final _logger = Logger.withTag('BackupScheduler');

  Timer? _timer;
  bool _inFlight = false;
  StreamSubscription<dynamic>? _deckSub;
  StreamSubscription<dynamic>? _cardSub;

  /// Subscribes to deck/card changes so any mutation schedules a backup. The
  /// first (initial) emission of each stream is skipped so launching the app
  /// with unchanged data does not upload. No-op on unsupported platforms.
  void start() {
    if (!icloudBackupService.isSupported) {
      _logger.d('start: unsupported platform, auto-backup disabled');
      return;
    }
    _deckSub ??=
        deckRepository.watchDecks().skip(1).listen((_) {
      _logger.d('deck change detected, scheduling backup');
      schedule();
    });
    _cardSub ??=
        quizCardRepository.watchCards().skip(1).listen((_) {
      _logger.d('card change detected, scheduling backup');
      schedule();
    });
    _logger.i('start: auto-backup watching deck & card changes');
    unawaited(_seedBackupIfMissing());
  }

  /// On launch, if the local library has cards but no (non-empty) iCloud backup
  /// exists yet, upload an initial backup immediately. This protects data that
  /// predates auto-backup (or was created while iCloud was unavailable) without
  /// waiting for the next change to trigger the watchers above.
  Future<void> _seedBackupIfMissing() async {
    try {
      if (!await icloudBackupService.isAvailable()) {
        _logger.d('_seedBackupIfMissing: iCloud unavailable, skipping');
        return;
      }
      final metadata = await icloudBackupService.fetchBackupMetadata();
      final backupEmpty = metadata == null ||
          (metadata.deckCount == 0 && metadata.cardCount == 0);
      if (!backupEmpty) {
        _logger.d('_seedBackupIfMissing: backup already present, skipping');
        return;
      }
      final cards = await quizCardRepository.watchCards().first;
      if (cards.isEmpty) {
        _logger.d('_seedBackupIfMissing: no local cards, nothing to back up');
        return;
      }
      _logger.i('_seedBackupIfMissing: backup empty but ${cards.length} local '
          'cards found, backing up now');
      await _runBackup();
    } catch (e, s) {
      _logger.e('_seedBackupIfMissing failed', ex: e, stacktrace: s);
    }
  }

  /// Requests a backup, coalescing bursts of changes into a single upload.
  void schedule() {
    if (!icloudBackupService.isSupported) return;
    _timer?.cancel();
    _logger.d('schedule: backup debounced for ${debounce.inSeconds}s');
    _timer = Timer(debounce, _runBackup);
  }

  Future<void> _runBackup() async {
    if (_inFlight) {
      // A backup is already running; reschedule so the latest state is saved.
      _logger.d('_runBackup: already in flight, rescheduling');
      schedule();
      return;
    }
    _inFlight = true;
    _logger.d('_runBackup: starting');
    try {
      if (!await icloudBackupService.isAvailable()) {
        _logger.w('_runBackup: iCloud unavailable, skipping upload');
        return;
      }

      final decks = await deckRepository.fetchDecks();
      final jsonPayload = await exportService.exportDecksToJson(decks);

      final cardCount = _countCards(jsonPayload);
      await icloudBackupService.saveBackup(
        jsonPayload: jsonPayload,
        deckCount: decks.length,
        cardCount: cardCount,
        version: version,
      );
      _logger.i(
          'iCloud backup saved (${decks.length} decks, $cardCount cards)');
    } catch (e, s) {
      _logger.e('iCloud backup failed', ex: e, stacktrace: s);
    } finally {
      _inFlight = false;
    }
  }

  int _countCards(String jsonPayload) {
    try {
      final decks = (jsonDecode(jsonPayload) as Map)['decks'] as List;
      return decks.fold<int>(
        0,
        (sum, deck) => sum + ((deck as Map)['cards'] as List).length,
      );
    } catch (_) {
      return 0;
    }
  }

  void dispose() {
    _logger.d('dispose: cancelling timer & subscriptions');
    _timer?.cancel();
    _deckSub?.cancel();
    _cardSub?.cancel();
  }
}
