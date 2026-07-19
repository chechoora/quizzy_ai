import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/user/model/quota_item.dart';
import 'package:poc_ai_quiz/domain/user/user_quota_repository.dart';
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
  final _logger = Logger.withTag('QuotaCubit');
  StreamSubscription? _subscription;

  QuotaCubit({
    required UserQuotaRepository repository,
  })  : _repository = repository,
        super(QuotaLoadingState());

  Future<void> loadQuota() async {
    emit(QuotaLoadingState());

    _subscription?.cancel();
    _subscription = _repository.fetchQuota().listen(
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
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
