import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/model/deck_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card_repository/quiz_card_repository.dart';

class QuizCardListCubit extends Cubit<QuizCardListState> {
  QuizCardListCubit({
    required this.deckItem,
    required this.quizCardRepository,
  }) : super(QuizCardListLoadingState());

  final DeckItem deckItem;
  final QuizCardRepository quizCardRepository;
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
      ..addAll(await quizCardRepository.fetchQuizCardItem(deckItem));
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

  void editQuizCard(QuizCardItem card, QuizCardRequestItem quizCardRequestItem) {
    emit(
      QuizCardListLoadingState(),
    );
    quizCardRepository.editQuizCard(
      currentCard: card,
      request: quizCardRequestItem,
    );
    fetchQuizCardListRequest();
  }

  void launchQuizRequest() {
    emit(
      QuizCardLaunchState(
        quizCarList: items,
      ),
    );
  }
}

abstract class QuizCardListState {}

class QuizCardListLoadingState extends QuizCardListState {}

class QuizCardListDataState extends QuizCardListState {
  QuizCardListDataState({required this.quizCarList});

  final List<QuizCardItem> quizCarList;
}

class QuizCardLaunchState extends QuizCardListState {
  QuizCardLaunchState({required this.quizCarList});

  final List<QuizCardItem> quizCarList;
}
