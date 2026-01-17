import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/util/view/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/home_widget/cubit/deck_cubit.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_display_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_widget.dart';

// TODO Add error messages
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final HomeCubit cubit = HomeCubit(
    deckRepository: getIt<DeckRepository>(),
    deckPremiumManager: getIt<DeckPremiumManager>(),
  );

  int _selectedIndex = 0;

  @override
  void initState() {
    cubit.fetchDecks();
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
        title: Text(
          "Quiz Decks",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: BlocConsumer<HomeCubit, DeckState>(
        bloc: cubit,
        buildWhen: (prevState, nextState) {
          return nextState is BuilderState;
        },
        builder: (BuildContext context, state) {
          if (state is DeckDataState) {
            if (_selectedIndex == 0) {
              return DeckListDisplayWidget(
                deckList: state.deckList,
                onDeckRemoveRequest: (deck) {
                  _launchConfirmDeleteRequest(deck);
                },
                onDeckEditRequest: (deck) {
                  _launchEditDeckTitleRequest(deck);
                },
                onDeckClicked: (deck) {
                  _openDeck(deck);
                },
              );
            } else if (_selectedIndex == 1) {
              return const SettingsWidget();
            }
            throw ArgumentError('Wrong index');
          }
          if (state is DeckLoadingState) {
            return const SimpleLoadingWidget();
          }
          throw ArgumentError('Wrong state');
        },
        listenWhen: (prevState, nextState) {
          return nextState is ListenerState;
        },
        listener: (BuildContext context, DeckState state) {
          if (state is RequestCreateDeckState) {
            if (state.canCreateDeck) {
              _addDockRequest();
            } else {
              _showCreateDeckPremiumError();
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/deck_icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                BlendMode.srcIn,
              ),
              semanticsLabel: 'Decks',
            ),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              tooltip: 'Add Deck',
              onPressed: () {
                cubit.addDockRequest();
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  void _addDockRequest() {
    context.push(CreateDeckRoute().path).then((deckName) {
      if (deckName is String) {
        cubit.createDeck(deckName);
      }
    });
  }

  void _launchConfirmDeleteRequest(DeckItem deck) {
    alert(
      context,
      content: Text(
        "Are you sure you want to delete ${deck.title}, all your quiz cards also will be deleted",
      ),
    ).then(
      (value) {
        if (value ?? false) {
          cubit.deleteDeck(deck);
        }
      },
    );
  }

  void _launchEditDeckTitleRequest(DeckItem deck) {
    context.push(CreateDeckRoute().path, extra: deck.title).then(
      (deckName) {
        if (deckName is String) {
          cubit.editDeck(deck, deckName);
        }
      },
    );
  }

  void _openDeck(DeckItem deck) {
    context.push(QuizCardListRoute().path, extra: deck);
  }

  void _showCreateDeckPremiumError() {
    alert(
      context,
      content: const Text(
        "You can not create more decks, please unlock the full version.",
      ),
      textOK: const Text("Unlock"),
    ).then(
      (value) {
        if (value ?? false) {
          // TODO Navigate to purchase screen
        }
      },
    );
  }
}
