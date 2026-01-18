import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class InAppFeaturesCubit extends Cubit<InAppFeaturesState> {
  InAppFeaturesCubit({
    required this.inAppPurchaseService,
  }) : super(const InAppFeaturesLoadingState()) {
    _logger = Logger.withTag('InAppFeaturesCubit');
  }

  final InAppPurchaseService inAppPurchaseService;
  late final Logger _logger;

  Future<void> loadFeatures() async {
    emit(const InAppFeaturesLoadingState());
    try {
      final isUnlimitedDecksCardsPurchased =
          await inAppPurchaseService.isFeaturePurchased(
        InAppPurchaseFeature.unlimitedDecksCards,
      );
      emit(InAppFeaturesDataState(
        isUnlimitedDecksCardsPurchased: isUnlimitedDecksCardsPurchased,
      ));
    } catch (e, stackTrace) {
      _logger.e('Failed to load features', ex: e, stacktrace: stackTrace);
      emit(InAppFeaturesErrorState(error: e.toString()));
    }
  }

  Future<void> purchaseUnlimitedDecksCards() async {
    final currentState = state;
    if (currentState is! InAppFeaturesDataState) return;

    emit(const InAppFeaturesPurchasingState());
    try {
      final result = await inAppPurchaseService.purchaseFeature(
        InAppPurchaseFeature.unlimitedDecksCards,
      );
      if (!result) {
        throw Exception('Purchase was not completed successfully');
      }
      emit(const InAppFeaturesPurchaseSuccessState());
      _logger.i('Purchased unlimited decks/cards feature');
      await loadFeatures();
    } catch (e, stackTrace) {
      _logger.e('Failed to purchase feature', ex: e, stacktrace: stackTrace);
      emit(InAppFeaturesErrorState(error: e.toString()));
      emit(currentState);
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
      emit(InAppFeaturesErrorState(error: e.toString()));
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

abstract class ListenerState extends InAppFeaturesState {
  const ListenerState();

  @override
  List<Object?> get props => [Object()];
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

class InAppFeaturesDataState extends BuilderState {
  final bool isUnlimitedDecksCardsPurchased;

  const InAppFeaturesDataState({
    required this.isUnlimitedDecksCardsPurchased,
  });

  @override
  List<Object?> get props => [isUnlimitedDecksCardsPurchased];
}

class InAppFeaturesPurchaseSuccessState extends ListenerState {
  const InAppFeaturesPurchaseSuccessState();

  @override
  List<Object?> get props => super.props;
}

class InAppFeaturesRestoreSuccessState extends ListenerState {
  const InAppFeaturesRestoreSuccessState();

  @override
  List<Object?> get props => super.props;
}

class InAppFeaturesErrorState extends ListenerState {
  final String error;

  const InAppFeaturesErrorState({required this.error});

  @override
  List<Object?> get props => [error, super.props];
}
