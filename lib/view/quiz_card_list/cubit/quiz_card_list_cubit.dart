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

  Future<void> fetchQuizCardList() async {
    emit(
      QuizCardListLoadingState(),
    );
    emit(
      QuizCardListDataState(
        quizCarList: await quizCardRepository.fetchQuizCardItem(deckItem),
      ),
    );
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
    fetchQuizCardList();
  }
}

abstract class QuizCardListState {}

class QuizCardListLoadingState extends QuizCardListState {}

class QuizCardListDataState extends QuizCardListState {
  QuizCardListDataState({required this.quizCarList});

  final List<QuizCardItem> quizCarList;
}
