import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/exception/in_app_purchase_exception.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class InAppFeaturesCubit extends Cubit<InAppFeaturesState> {
  InAppFeaturesCubit({
    required this.inAppPurchaseService,
    required this.settingsService,
    required this.isSubscriptionOnly,
  }) : super(const InAppFeaturesLoadingState()) {
    _logger = Logger.withTag('InAppFeaturesCubit');
  }

  final InAppPurchaseService inAppPurchaseService;
  final SettingsService settingsService;

  /// When true (the `quizzypro` flavor) only the Quizzy AI subscription is
  /// offered; when false (the `quizzy` flavor) only the one-time "unlimited
  /// decks/cards" purchase is offered.
  final bool isSubscriptionOnly;

  late final Logger _logger;

  List<PurchaseOption> _options = const [];
  String? _selectedPackageIdentifier;

  Future<void> loadFeatures() async {
    emit(const InAppFeaturesLoadingState());
    try {
      if (isSubscriptionOnly) {
        final isSubscribed = await inAppPurchaseService.isFeaturePurchased(
          InAppPurchaseFeature.quizzyAi,
        );
        if (!isSubscribed) {
          await _loadPurchaseOptions();
        }
        emit(InAppFeaturesQuizzyAiState(
          isSubscribed: isSubscribed,
          options: _options,
          selectedPackageIdentifier: _selectedPackageIdentifier,
        ));
      } else {
        final isPurchased = await inAppPurchaseService.isFeaturePurchased(
          InAppPurchaseFeature.unlimitedDecksCards,
        );
        emit(InAppFeaturesFullUnlockState(isPurchased: isPurchased));
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to load features', ex: e, stacktrace: stackTrace);
      emit(const InAppFeaturesErrorState(exception: InAppPurchaseException()));
    }
  }

  Future<void> _loadPurchaseOptions() async {
    _logger.d('Loading purchase options for quizzyAi');
    try {
      final options = await inAppPurchaseService
          .getPurchaseOptions(InAppPurchaseFeature.quizzyAi);
      _options = options;
      _selectedPackageIdentifier = options
              .firstWhereOrNull((o) => o.period == SubscriptionPeriod.yearly)
              ?.packageIdentifier ??
          options.firstOrNull?.packageIdentifier;
      _logger.i('Loaded ${options.length} purchase options');
    } catch (e, stackTrace) {
      _logger.e('Failed to load purchase options',
          ex: e, stacktrace: stackTrace);
    }
  }

  void selectOption(String packageIdentifier) {
    final currentState = state;
    if (currentState is! InAppFeaturesQuizzyAiState) return;
    _logger.d('Selected purchase option: $packageIdentifier');
    _selectedPackageIdentifier = packageIdentifier;
    emit(InAppFeaturesQuizzyAiState(
      isSubscribed: currentState.isSubscribed,
      options: _options,
      selectedPackageIdentifier: _selectedPackageIdentifier,
    ));
  }

  Future<void> purchase() async {
    final currentState = state;
    if (currentState is! InAppFeaturesDataState) return;

    emit(const InAppFeaturesPurchasingState());
    try {
      final feature = isSubscriptionOnly
          ? InAppPurchaseFeature.quizzyAi
          : InAppPurchaseFeature.unlimitedDecksCards;
      final result = await inAppPurchaseService.purchaseFeature(
        feature,
        packageIdentifier: isSubscriptionOnly ? _selectedPackageIdentifier : null,
      );
      if (!result) {
        throw Exception('Purchase was not completed successfully');
      }
      emit(const InAppFeaturesPurchaseSuccessState());
      _logger.i('Purchased feature $feature');
      if (isSubscriptionOnly) {
        await _setQuizzyAiAsDefault();
      }
      await loadFeatures();
    } catch (e, stackTrace) {
      _logger.e('Failed to purchase feature', ex: e, stacktrace: stackTrace);
      emit(const InAppFeaturesErrorState(exception: InAppPurchaseException()));
      emit(currentState);
    }
  }

  Future<void> _setQuizzyAiAsDefault() async {
    _logger.d('Setting Quizzy AI as default validator and deck generator');
    try {
      await settingsService.updateValidatorType(AnswerValidatorType.quizzyAI);
      await settingsService
          .updateDeckGenerationAiType(AnswerValidatorType.quizzyAI);
      _logger.i('Quizzy AI set as default validator and deck generator');
    } catch (e, stackTrace) {
      _logger.e('Failed to set Quizzy AI as default',
          ex: e, stacktrace: stackTrace);
    }
  }

  Future<void> restorePurchases() async {
    final currentState = state;
    if (currentState is! InAppFeaturesDataState) return;

    emit(const InAppFeaturesRestoringState());
    try {
      await inAppPurchaseService.restorePurchasedFeatures();
      emit(const InAppFeaturesRestoreSuccessState());
      _logger.i('Restored purchases');
      await loadFeatures();
    } catch (e, stackTrace) {
      _logger.e('Failed to restore purchases', ex: e, stacktrace: stackTrace);
      emit(const InAppFeaturesErrorState(exception: InAppPurchaseException()));
      emit(currentState);
    }
  }
}

abstract class InAppFeaturesState extends Equatable {
  const InAppFeaturesState();
}

abstract class BuilderState extends InAppFeaturesState {
  const BuilderState();
}

abstract class ListenerState extends InAppFeaturesState with UniqueEmit {
  const ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class InAppFeaturesLoadingState extends BuilderState {
  const InAppFeaturesLoadingState();

  @override
  List<Object?> get props => [];
}

class InAppFeaturesPurchasingState extends BuilderState {
  const InAppFeaturesPurchasingState();

  @override
  List<Object?> get props => [];
}

class InAppFeaturesRestoringState extends BuilderState {
  const InAppFeaturesRestoringState();

  @override
  List<Object?> get props => [];
}

abstract class InAppFeaturesDataState extends BuilderState {
  const InAppFeaturesDataState();
}

class InAppFeaturesFullUnlockState extends InAppFeaturesDataState {
  final bool isPurchased;

  const InAppFeaturesFullUnlockState({required this.isPurchased});

  @override
  List<Object?> get props => [isPurchased];
}

class InAppFeaturesQuizzyAiState extends InAppFeaturesDataState {
  final bool isSubscribed;
  final List<PurchaseOption> options;
  final String? selectedPackageIdentifier;

  const InAppFeaturesQuizzyAiState({
    required this.isSubscribed,
    this.options = const [],
    this.selectedPackageIdentifier,
  });

  @override
  List<Object?> get props => [isSubscribed, options, selectedPackageIdentifier];
}

class InAppFeaturesPurchaseSuccessState extends ListenerState {
  const InAppFeaturesPurchaseSuccessState();
}

class InAppFeaturesRestoreSuccessState extends ListenerState {
  const InAppFeaturesRestoreSuccessState();
}

class InAppFeaturesErrorState extends ListenerState {
  final InAppPurchaseException exception;

  const InAppFeaturesErrorState({required this.exception});
}
