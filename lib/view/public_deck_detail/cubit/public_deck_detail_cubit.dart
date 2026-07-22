import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_detail.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/public_decks_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class PublicDeckDetailCubit extends Cubit<PublicDeckDetailState> {
  PublicDeckDetailCubit({
    required this.deckId,
    required this.publicDecksRepository,
    required this.logger,
  }) : super(PublicDeckDetailLoadingState());

  final String deckId;
  final PublicDecksRepository publicDecksRepository;
  final Logger logger;

  Future<void> loadDeck() async {
    logger.d('loadDeck: deckId=$deckId');
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
}

abstract class PublicDeckDetailState extends Equatable {
  const PublicDeckDetailState();
}

abstract class BuilderState extends PublicDeckDetailState {
  const BuilderState();
}

class PublicDeckDetailLoadingState extends BuilderState {
  @override
  List<Object?> get props => [];
}

class PublicDeckDetailDataState extends BuilderState {
  const PublicDeckDetailDataState({required this.deckDetail});

  final PublicDeckDetail deckDetail;

  @override
  List<Object?> get props => [deckDetail];
}

class PublicDeckDetailErrorState extends BuilderState {
  @override
  List<Object?> get props => [];
}
