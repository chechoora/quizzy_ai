import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/model/deck_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card_repository/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/cubit/quiz_card_list_cubit.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/fill_quiz_card_data.dart';
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
    cubit.fetchQuizCardListRequest();
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
        buildWhen: (oldState, newState) {
          return newState is! QuizCardLaunchState;
        },
        builder: (context, state) {
          if (state is QuizCardListDataState) {
            return QuizCardListDisplayWidget(
              quizCarList: state.quizCarList,
              onQuizCardEditRequest: (card) {
                _launchEditCardRequest(card);
              },
              onQuizCardRemoveRequest: (card) {
                _launchConfirmDeleteRequest(card);
              },
            );
          }
          if (state is QuizCardListLoadingState) {
            return const SimpleLoadingWidget();
          }
          throw ArgumentError('Wrong state');
        },
        listenWhen: (oldState, newState) {
          return newState is QuizCardLaunchState;
        },
        listener: (context, state) {
          if (state is QuizCardLaunchState) {
            context.push(
              '/quizExe',
              extra: state.quizCarList,
            );
          }
        },
      ),
      bottomNavigationBar: _BottomQuizCardBar(
        onAddCardRequest: () {
          _addCardRequest();
        },
        onLaunchQuizRequest: () {
          cubit.launchQuizRequest();
        },
      ),
    );
  }

  void _addCardRequest() {
    QuizCardRequestItem? quizCardRequestItem;
    alert(
      context,
      title: const Text("Add Quiz Card"),
      content: FillQuizCardData(
        onValueChange: (cardRequestItem) {
          quizCardRequestItem = cardRequestItem;
        },
      ),
    ).then((value) {
      if (validateQuizCard(quizCardRequestItem) && (value ?? false)) {
        cubit.createQuizCardItem(quizCardRequestItem!);
      }
    });
  }

  // TODO add alert
  bool validateQuizCard(QuizCardRequestItem? quizCardRequestItem) {
    return quizCardRequestItem != null &&
        quizCardRequestItem.question.isNotEmpty &&
        quizCardRequestItem.answer.isNotEmpty;
  }

  void _launchConfirmDeleteRequest(QuizCardItem card) {
    alert(
      context,
      content: const Text(
        "Are you sure you want to delete current card?",
      ),
    ).then(
      (value) {
        if (value ?? false) {
          cubit.deleteCard(card);
        }
      },
    );
  }

  void _launchEditCardRequest(QuizCardItem card) {
    QuizCardRequestItem? quizCardRequestItem;
    alert(
      context,
      title: const Text("Edit Quiz Card"),
      content: FillQuizCardData(
        cardItemForEdit: card,
        onValueChange: (cardRequestItem) {
          quizCardRequestItem = cardRequestItem;
        },
      ),
    ).then((value) {
      if (validateQuizCard(quizCardRequestItem) && (value ?? false)) {
        cubit.editQuizCard(card, quizCardRequestItem!);
      }
    });
  }
}

class _BottomQuizCardBar extends StatelessWidget {
  const _BottomQuizCardBar({
    this.onAddCardRequest,
    this.onLaunchQuizRequest,
  });

  final VoidCallback? onAddCardRequest;
  final VoidCallback? onLaunchQuizRequest;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Add Card',
            icon: const Icon(Icons.add),
            onPressed: onAddCardRequest,
          ),
          IconButton(
            tooltip: 'Launch Deck',
            icon: const Icon(Icons.play_arrow),
            onPressed: onLaunchQuizRequest,
          ),
        ],
      ),
    );
  }
}
