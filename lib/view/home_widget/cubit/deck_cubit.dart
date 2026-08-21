import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/backup_scheduler.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_restore_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/onboarding/onboarding_service.dart';

class HomeCubit extends Cubit<DeckState> {
  HomeCubit({
    required this.deckRepository,
    required this.deckPremiumManager,
    required this.onboardingService,
    required this.iCloudRestoreService,
    required this.backupScheduler,
    required this.isSubscriptionOnly,
  }) : super(const DeckLoadingState());

  final DeckRepository deckRepository;
  final DeckPremiumManager deckPremiumManager;
  final OnboardingService onboardingService;
  final ICloudRestoreService iCloudRestoreService;
  final BackupScheduler backupScheduler;

  /// When true (the `quizzypro` flavor) only the Quizzy AI subscription is
  /// offered; when false (the `quizzy` flavor) only the one-time "unlimited
  /// decks/cards" purchase is offered.
  final bool isSubscriptionOnly;

  final List<DeckItem> decks = [];
  StreamSubscription<List<DeckItem>>? _decksSubscription;

  /// The purchase feature to offer when the deck limit is hit, resolved from
  /// the active flavor: `quizzyAi` subscription on `quizzypro`, the one-time
  /// `unlimitedDecksCards` purchase on `quizzy`.
  InAppPurchaseFeature get unlockFeature => isSubscriptionOnly
      ? InAppPurchaseFeature.quizzyAi
      : InAppPurchaseFeature.unlimitedDecksCards;

  void watchDecks() {
    _decksSubscription?.cancel();
    _decksSubscription = deckRepository.watchDecks().listen(
      (data) {
        decks
          ..clear()
          ..addAll(data);
        emit(DeckDataState(data));
      },
    );
  }

  Future<void> createDeck(String deckName) async {
    final deckId = await deckRepository.saveDeck(deckName);
    final deck = await deckRepository.watchDeck(deckId).first;
    if (deck != null) {
      emit(DeckCreatedState(deck));
    }
  }

  void deleteDeck(DeckItem deck) {
    deckRepository.deleteDeck(deck);
  }

  void editDeck(DeckItem deck, String deckName) {
    deckRepository.editDeckName(deck, deckName);
  }

  Future<void> checkOnboarding() async {
    final completed = await onboardingService.isOnboardingCompleted();
    if (!completed) {
      emit(const ShowOnboardingState());
    } else {
      // Returning users don't go through startOnboardingFlow (the only other
      // caller of checkICloudRestore), so this is their only chance per
      // launch to be offered a restore / to unblock the backup scheduler.
      await checkICloudRestore();
    }
  }

  Future<void> completeOnboarding() {
    return onboardingService.completeOnboarding();
  }

  /// On a clean install, decides whether to offer a one-time iCloud restore and
  /// emits [ShowICloudRestoreState] if so (marking the prompt as shown). The
  /// backup scheduler must not start watching for local changes until this
  /// decision is resolved — starting earlier risks uploading a sparse local
  /// snapshot that overwrites a fuller cloud backup before it's ever restored
  /// (see restoreFromICloud/skipICloudRestore for the other resolution
  /// points). When there's nothing to offer, it's already safe to start.
  Future<void> checkICloudRestore() async {
    if (await iCloudRestoreService.shouldOfferRestore()) {
      await iCloudRestoreService.markPromptShown();
      emit(const ShowICloudRestoreState());
    } else {
      backupScheduler.start();
    }
  }

  Future<void> restoreFromICloud() async {
    try {
      final restoredCount = await iCloudRestoreService.restore();
      if (restoredCount != null) {
        emit(ICloudRestoreSuccessState(restoredCount));
      }
    } on ImportLimitExceededException catch (e) {
      emit(ICloudRestoreLimitState(e));
    } catch (_) {
      emit(const ICloudRestoreErrorState());
    } finally {
      backupScheduler.start();
    }
  }

  /// Called when the user declines the clean-install restore offer — nothing
  /// to restore for this launch, so it's now safe to start the backup
  /// scheduler.
  void skipICloudRestore() {
    backupScheduler.start();
  }

  void addDockRequest() async {
    final canAddDecks = await deckPremiumManager.canAddDeck();
    emit(
      RequestCreateDeckState(
        canCreateDeck: canAddDecks,
      ),
    );
  }

  @override
  Future<void> close() {
    _decksSubscription?.cancel();
    return super.close();
  }
}

abstract class DeckState extends Equatable {
  const DeckState();
}

abstract class BuilderState extends DeckState {
  const BuilderState();
}

abstract class ListenerState extends DeckState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
}

class DeckLoadingState extends BuilderState {
  const DeckLoadingState();

  @override
  List<Object?> get props => [];
}

class DeckDataState extends BuilderState {
  final List<DeckItem> deckList;

  const DeckDataState(this.deckList);

  @override
  List<Object?> get props => [deckList];
}

class DeckCreatedState extends ListenerState {
  final DeckItem deck;

  const DeckCreatedState(this.deck);
}

class RequestCreateDeckState extends ListenerState {
  final bool canCreateDeck;

  const RequestCreateDeckState({
    required this.canCreateDeck,
  });
}

class ShowOnboardingState extends ListenerState {
  const ShowOnboardingState();
}

class ShowICloudRestoreState extends ListenerState {
  const ShowICloudRestoreState();
}

class ICloudRestoreSuccessState extends ListenerState {
  const ICloudRestoreSuccessState(this.deckCount);

  final int deckCount;
}

class ICloudRestoreLimitState extends ListenerState {
  const ICloudRestoreLimitState(this.exception);

  final ImportLimitExceededException exception;
}

class ICloudRestoreErrorState extends ListenerState {
  const ICloudRestoreErrorState();
}
