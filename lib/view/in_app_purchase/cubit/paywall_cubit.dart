import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit({
    required this.inAppPurchaseService,
    required this.feature,
  }) : super(const PaywallIdleState()) {
    _logger = Logger.withTag('PaywallCubit');
    if (feature == InAppPurchaseFeature.quizzyAi) {
      _loadOptions();
    }
  }

  final InAppPurchaseService inAppPurchaseService;
  final InAppPurchaseFeature feature;
  late final Logger _logger;

  List<PurchaseOption> _options = const [];
  String? _selectedPackageIdentifier;

  Future<void> _loadOptions() async {
    _logger.d('Loading purchase options for $feature');
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
    _logger.d('Selected purchase option: $packageIdentifier');
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
      emit(const PaywallPurchaseSuccessState());
    } catch (e, st) {
      _logger.e('Purchase failed', ex: e, stacktrace: st);
      emit(const PaywallErrorState(message: 'Purchase failed'));
      emit(_idleState());
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
