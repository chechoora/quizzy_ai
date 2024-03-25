import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_request_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/cubit/quiz_card_list_cubit.dart';
import 'package:poc_ai_quiz/view/quiz_card_list/display/quiz_card_list_display_widget.dart';

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
    quizCardPremiumManager: getIt<QuizCardPremiumManager>(),
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
        automaticallyImplyLeading: false,
        title: Text(
          widget.deckItem.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: BlocConsumer<QuizCardListCubit, QuizCardListState>(
        bloc: cubit,
        buildWhen: (oldState, newState) {
          return newState is BuilderState;
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
          return newState is ListenerState;
        },
        listener: (context, state) {
          if (state is QuizCardLaunchState) {
            context.push(
              '/quizExe',
              extra: state.quizCarList,
            );
          }
          if (state is RequestCreateQuizCardState) {
            if (state.canCreateCard) {
              _addCardRequest();
            } else {
              _showCreateCardPremiumError();
            }
          }
        },
      ),
      bottomNavigationBar: _BottomQuizCardBar(
        onBackRequest: () {
          context.pop();
        },
        onAddCardRequest: () {
          cubit.addCardRequest();
        },
        onLaunchQuizRequest: () {
          cubit.launchQuizRequest();
        },
      ),
    );
  }

  void _addCardRequest() {
    context.push('/createCard').then((cardRequest) {
      if (cardRequest is QuizCardRequestItem) {
        cubit.createQuizCardItem(cardRequest);
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
    context.push('/createCard', extra: card).then((cardRequest) {
      if (cardRequest is QuizCardRequestItem) {
        cubit.editQuizCard(card, cardRequest);
      }
    });
  }

  void _showCreateCardPremiumError() {
    alert(
      context,
      content: const Text(
        "You can not create more cards, please unlock the full version.",
      ),
    ).then(
      (value) {
        if (value ?? false) {}
      },
    );
  }
}

class _BottomQuizCardBar extends StatelessWidget {
  const _BottomQuizCardBar({
    this.onBackRequest,
    this.onAddCardRequest,
    this.onLaunchQuizRequest,
  });

  final VoidCallback? onBackRequest;
  final VoidCallback? onAddCardRequest;
  final VoidCallback? onLaunchQuizRequest;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onBackRequest,
          ),
          IconButton(
            tooltip: 'Add Card',
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onAddCardRequest,
          ),
          IconButton(
            tooltip: 'Launch Deck',
            icon: Icon(
              Icons.play_arrow,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onLaunchQuizRequest,
          ),
        ],
      ),
    );
  }
}
