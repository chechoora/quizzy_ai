import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_exe_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class QuizCardListCubit extends Cubit<QuizCardListState> {
  QuizCardListCubit({
    required this.deckItem,
    required this.quizCardRepository,
    required this.quizCardPremiumManager,
    required this.quizCardExeValidator,
  }) : super(QuizCardListLoadingState());

  final DeckItem deckItem;
  final QuizCardRepository quizCardRepository;
  final QuizCardPremiumManager quizCardPremiumManager;
  final QuizCardExeValidator quizCardExeValidator;
  final items = <QuizCardItem>[];

  Future<void> fetchQuizCardListRequest() async {
    emit(
      QuizCardListLoadingState(),
    );
    emit(
      QuizCardListDataState(
        quizCarList: await _fetchCards(),
      ),
    );
  }

  Future<List<QuizCardItem>> _fetchCards() async {
    return items
      ..clear()
      ..addAll(await quizCardPremiumManager.fetchAllowedQuizCard(deckItem));
  }

  void createQuizCardItem(QuizCardRequestItem requestItem) {
    emit(
      QuizCardListLoadingState(),
    );
    quizCardRepository.saveQuizCard(
      question: requestItem.question,
      answer: requestItem.answer,
      deckId: deckItem.id,
    );
    fetchQuizCardListRequest();
  }

  void deleteCard(QuizCardItem card) {
    emit(
      QuizCardListLoadingState(),
    );
    quizCardRepository.deleteQuizCard(card);
    fetchQuizCardListRequest();
  }

  void editQuizCard(
      QuizCardItem card, QuizCardRequestItem quizCardRequestItem) {
    emit(
      QuizCardListLoadingState(),
    );
    quizCardRepository.editQuizCard(
      currentCard: card,
      request: quizCardRequestItem,
    );
    fetchQuizCardListRequest();
  }

  Future<void> launchQuizRequest({
    bool isQuickPlay = false,
    bool isShuffle = false,
  }) async {
    final result = await quizCardExeValidator.isExeValid();
    final cars = List<QuizCardItem>.from(items);
    if (isShuffle) {
      cars.shuffle();
    }
    if (result is QuizCardExeValid) {
      emit(
        QuizCardLaunchState(
          quizCarList: cars,
          isQuickPlay: isQuickPlay,
        ),
      );
    } else {
      emit(
        QuizCardListErrorState(
          message: (result as QuizCardExeInvalid).reason,
        ),
      );
    }
  }

  void addCardRequest() async {
    final canAddCard = await quizCardPremiumManager.canAddQuizCard(deckItem);
    emit(
      RequestCreateQuizCardState(
        canCreateCard: canAddCard,
      ),
    );
  }
}

abstract class QuizCardListState extends Equatable {
  const QuizCardListState();
}

abstract class BuilderState extends QuizCardListState {
  const BuilderState();
}

abstract class ListenerState extends QuizCardListState with UniqueEmit {
  ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class QuizCardListLoadingState extends BuilderState {
  @override
  List<Object?> get props => [];
}

class QuizCardListDataState extends BuilderState {
  const QuizCardListDataState({required this.quizCarList});

  final List<QuizCardItem> quizCarList;

  @override
  List<Object?> get props => [quizCarList];
}

class QuizCardLaunchState extends ListenerState {
  QuizCardLaunchState({
    required this.quizCarList,
    this.isQuickPlay = false,
  });

  final List<QuizCardItem> quizCarList;
  final bool isQuickPlay;
}

class RequestCreateQuizCardState extends ListenerState {
  final bool canCreateCard;

  RequestCreateQuizCardState({
    required this.canCreateCard,
  });
}

class QuizCardListErrorState extends ListenerState {
  final String message;

  QuizCardListErrorState({required this.message});
}
