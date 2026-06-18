import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit({
    required this.inAppPurchaseService,
    required this.feature,
  }) : super(const PaywallIdleState()) {
    _logger = Logger.withTag('PaywallCubit');
  }

  final InAppPurchaseService inAppPurchaseService;
  final InAppPurchaseFeature feature;
  late final Logger _logger;

  Future<void> purchase() async {
    emit(const PaywallLoadingState());
    try {
      final success =
          await inAppPurchaseService.purchaseFeature(feature);
      if (!success) {
        emit(const PaywallIdleState());
        return;
      }
      emit(const PaywallPurchaseSuccessState());
    } catch (e, st) {
      _logger.e('Purchase failed', ex: e, stacktrace: st);
      emit(const PaywallErrorState(message: 'Purchase failed'));
      emit(const PaywallIdleState());
    }
  }

  Future<void> restore() async {
    emit(const PaywallLoadingState());
    try {
      await inAppPurchaseService.restorePurchasedFeatures();
      final purchased =
          await inAppPurchaseService.isFeaturePurchased(feature);
      if (!purchased) {
        emit(const PaywallIdleState());
        return;
      }
      emit(const PaywallRestoreSuccessState());
    } catch (e, st) {
      _logger.e('Restore failed', ex: e, stacktrace: st);
      emit(const PaywallErrorState(message: 'Restore failed'));
      emit(const PaywallIdleState());
    }
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
