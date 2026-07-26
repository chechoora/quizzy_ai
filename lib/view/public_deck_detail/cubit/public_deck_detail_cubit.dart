import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_detail.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/public_decks_repository.dart';
import 'package:poc_ai_quiz/domain/sync/sync_scheduler.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class PublicDeckDetailCubit extends Cubit<PublicDeckDetailState> {
  PublicDeckDetailCubit({
    required this.deckId,
    required this.publicDecksRepository,
    required this.syncScheduler,
    required this.logger,
  }) : super(PublicDeckDetailLoadingState());

  final String deckId;
  final PublicDecksRepository publicDecksRepository;
  final SyncScheduler syncScheduler;
  final Logger logger;

  Future<void> loadDeck() async {
    logger.i('loadDeck: deckId=$deckId');
    emit(PublicDeckDetailLoadingState());
    try {
      final deckDetail = await publicDecksRepository.getPublicDeck(deckId);
      logger.i('loadDeck: success, ${deckDetail.cards.length} cards');
      emit(PublicDeckDetailDataState(deckDetail: deckDetail));
    } catch (e, stackTrace) {
      logger.e('loadDeck: failed', ex: e, stacktrace: stackTrace);
      emit(PublicDeckDetailErrorState());
    }
  }

  Future<void> copyDeck() async {
    final currentState = state;
    if (currentState is! PublicDeckDetailDataState || currentState.isCopying) {
      logger.i('copyDeck: skipped, currentState=$currentState');
      return;
    }
    final deckDetail = currentState.deckDetail;
    logger.i('copyDeck: deckId=$deckId');
    emit(PublicDeckDetailDataState(deckDetail: deckDetail, isCopying: true));
    try {
      await publicDecksRepository.copyPublicDeck(deckId);
      await syncScheduler.syncNow();
      logger.i('copyDeck: success, deckId=$deckId');
      emit(PublicDeckDetailCopySuccessState());
      emit(PublicDeckDetailDataState(deckDetail: deckDetail, isCopying: false));
    } catch (e, stackTrace) {
      logger.e('copyDeck: failed', ex: e, stacktrace: stackTrace);
      emit(PublicDeckDetailCopyErrorState());
      emit(PublicDeckDetailDataState(deckDetail: deckDetail, isCopying: false));
    }
  }
}

abstract class PublicDeckDetailState extends Equatable {
  const PublicDeckDetailState();
}

abstract class BuilderState extends PublicDeckDetailState {
  const BuilderState();
}

abstract class ListenerState extends PublicDeckDetailState with UniqueEmit {
  ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class PublicDeckDetailLoadingState extends BuilderState {
  @override
  List<Object?> get props => [];
}

class PublicDeckDetailDataState extends BuilderState {
  const PublicDeckDetailDataState({
    required this.deckDetail,
    this.isCopying = false,
  });

  final PublicDeckDetail deckDetail;
  final bool isCopying;

  @override
  List<Object?> get props => [deckDetail, isCopying];
}

class PublicDeckDetailErrorState extends BuilderState {
  @override
  List<Object?> get props => [];
}

class PublicDeckDetailCopySuccessState extends ListenerState {}

class PublicDeckDetailCopyErrorState extends ListenerState {}
