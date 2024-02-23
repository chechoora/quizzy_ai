import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card_repository/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/cubit/quiz_card_list_cubit.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/quiz_card_list_display_widget.dart';

class QuizCardListWidget extends StatefulWidget {
  const QuizCardListWidget({
    required this.deckItem,
    super.key,
  });

  final DeckItem deckItem;

  @override
  State<QuizCardListWidget> createState() => _QuizCardListWidgetState();
}

class _QuizCardListWidgetState extends State<QuizCardListWidget> {
  late final QuizCardListCubit cubit = QuizCardListCubit(
    deckItem: widget.deckItem,
    quizCardRepository: getIt<QuizCardRepository>(),
  );

  @override
  void initState() {
    cubit.fetchQuizCardList();
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Deck Cards",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<QuizCardListCubit, QuizCardListState>(
        bloc: cubit,
        builder: (context, state) {
          if (state is QuizCardListDataState) {
            return QuizCardListDisplayWidget(
              quizCarList: state.quizCarList,
            );
          }
          if (state is QuizCardListLoadingState) {
            return const SimpleLoadingWidget();
          }
          throw ArgumentError('Wrong state');
        },
        listener: (context, state) {},
      ),
    );
  }
}
