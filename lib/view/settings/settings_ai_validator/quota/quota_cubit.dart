import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/user/model/quota_item.dart';
import 'package:poc_ai_quiz/domain/user/user_quota_repository.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';

sealed class QuotaState {}

class QuotaLoadingState extends QuotaState {}

class QuotaDataState extends QuotaState {
  final QuotaItem quota;

  QuotaDataState(this.quota);
}

class QuotaErrorState extends QuotaState {
  final String error;

  QuotaErrorState(this.error);
}

class QuotaCubit extends Cubit<QuotaState> {
  final UserQuotaRepository _repository;
  final InAppPurchaseService _inAppPurchaseService;
  final _logger = Logger.withTag('QuotaCubit');
  StreamSubscription? _subscription;

  QuotaCubit({
    required UserQuotaRepository repository,
    required InAppPurchaseService inAppPurchaseService,
  })  : _repository = repository,
        _inAppPurchaseService = inAppPurchaseService,
        super(QuotaLoadingState());

  Future<void> loadQuota() async {
    emit(QuotaLoadingState());

    try {
      final appUserId = await _inAppPurchaseService
          .getAppUserId(InAppPurchaseFeature.quizzyAi);

      _subscription?.cancel();
      _subscription = _repository.fetchQuota(appUserId).listen(
        (quota) {
          _logger.d(
              'Quota loaded: ${quota.weeklyPercentUsage}%, ${quota.questionsLeft} left');
          emit(QuotaDataState(quota));
        },
        onError: (error, stackTrace) {
          _logger.e('Failed to load quota', ex: error, stacktrace: stackTrace);
          emit(QuotaErrorState(error.toString()));
        },
      );
    } catch (error, stackTrace) {
      _logger.e('Failed to fetch user', ex: error, stacktrace: stackTrace);
      emit(QuotaErrorState('Failed to load user data'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
