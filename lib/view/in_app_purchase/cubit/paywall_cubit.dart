import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_events.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit({
    required this.inAppPurchaseService,
    required this.analyticsService,
    required this.settingsService,
    required this.feature,
  }) : super(const PaywallIdleState()) {
    _logger = Logger.withTag('PaywallCubit');
    if (feature == InAppPurchaseFeature.quizzyAi) {
      _loadOptions();
    }
  }

  final InAppPurchaseService inAppPurchaseService;
  final AnalyticsService analyticsService;
  final SettingsService settingsService;
  final InAppPurchaseFeature feature;
  late final Logger _logger;

  /// True when this paywall is offering the Quizzy AI subscription itself
  /// (as opposed to a one-time "unlimited decks/cards" purchase).
  bool get isSubscriptionOnly => feature == InAppPurchaseFeature.quizzyAi;

  List<PurchaseOption> _options = const [];
  String? _selectedPackageIdentifier;

  Future<void> _loadOptions() async {
    _logger.i('Loading purchase options for $feature');
    emit(const PaywallLoadingState());
    try {
      final options = await inAppPurchaseService.getPurchaseOptions(feature);
      _options = options;
      _selectedPackageIdentifier = options
              .firstWhereOrNull((o) => o.period == SubscriptionPeriod.yearly)
              ?.packageIdentifier ??
          options.firstOrNull?.packageIdentifier;
      _logger.i('Loaded ${options.length} purchase options');
      emit(_idleState());
    } catch (e, st) {
      _logger.e('Failed to load purchase options', ex: e, stacktrace: st);
      emit(const PaywallErrorState(message: 'Failed to load purchase options'));
      emit(const PaywallIdleState());
    }
  }

  void selectOption(String packageIdentifier) {
    _logger.i('Selected purchase option: $packageIdentifier');
    _selectedPackageIdentifier = packageIdentifier;
    emit(_idleState());
  }

  Future<void> purchase() async {
    emit(const PaywallLoadingState());
    try {
      final success = await inAppPurchaseService.purchaseFeature(
        feature,
        packageIdentifier: _selectedPackageIdentifier,
      );
      if (!success) {
        emit(_idleState());
        return;
      }
      final option = _options
          .firstWhereOrNull((o) => o.packageIdentifier == _selectedPackageIdentifier);
      unawaited(analyticsService.track(AnalyticsEvents.subscriptionStarted, properties: {
        AnalyticsProperties.offering: feature.toOfferingId(),
        if (option != null) AnalyticsProperties.plan: option.period.name,
      }));
      if (isSubscriptionOnly) {
        await _setQuizzyAiAsDefault();
      }
      emit(const PaywallPurchaseSuccessState());
    } catch (e, st) {
      _logger.e('Purchase failed', ex: e, stacktrace: st);
      emit(const PaywallErrorState(message: 'Purchase failed'));
      emit(_idleState());
    }
  }

  Future<void> _setQuizzyAiAsDefault() async {
    _logger.i('Setting Quizzy AI as default validator and deck generator');
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

  Future<void> restore() async {
    emit(const PaywallLoadingState());
    try {
      await inAppPurchaseService.restorePurchasedFeatures();
      final purchased =
          await inAppPurchaseService.isFeaturePurchased(feature);
      if (!purchased) {
        emit(_idleState());
        return;
      }
      emit(const PaywallRestoreSuccessState());
    } catch (e, st) {
      _logger.e('Restore failed', ex: e, stacktrace: st);
      emit(const PaywallErrorState(message: 'Restore failed'));
      emit(_idleState());
    }
  }

  PaywallState _idleState() {
    if (_options.isEmpty) {
      return const PaywallIdleState();
    }
    return PaywallOptionsState(
      options: _options,
      selectedPackageIdentifier: _selectedPackageIdentifier,
    );
  }
}

abstract class PaywallState extends Equatable {
  const PaywallState();
}

abstract class BuilderState extends PaywallState {
  const BuilderState();
}

abstract class ListenerState extends PaywallState with UniqueEmit {
  const ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class PaywallIdleState extends BuilderState {
  const PaywallIdleState();

  @override
  List<Object?> get props => [];
}

class PaywallLoadingState extends BuilderState {
  const PaywallLoadingState();

  @override
  List<Object?> get props => [];
}

class PaywallOptionsState extends BuilderState {
  final List<PurchaseOption> options;
  final String? selectedPackageIdentifier;

  const PaywallOptionsState({
    required this.options,
    required this.selectedPackageIdentifier,
  });

  @override
  List<Object?> get props => [options, selectedPackageIdentifier];
}

class PaywallPurchaseSuccessState extends ListenerState {
  const PaywallPurchaseSuccessState();
}

class PaywallRestoreSuccessState extends ListenerState {
  const PaywallRestoreSuccessState();
}

class PaywallErrorState extends ListenerState {
  final String message;

  const PaywallErrorState({required this.message});
}
