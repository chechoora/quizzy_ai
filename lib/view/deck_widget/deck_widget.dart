import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';
import 'package:poc_ai_quiz/view/deck_widget/cubit/deck_cubit.dart';
import 'package:poc_ai_quiz/view/deck_widget/deck_list_display_widget.dart';
import 'package:poc_ai_quiz/view/deck_widget/fill_deck_data_widget.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_widget.dart';

//TODO Add validation for dialogs.
// TODO Add error messages
class DeckWidget extends StatefulWidget {
  const DeckWidget({super.key});

  @override
  State<DeckWidget> createState() => _DeckWidgetState();
}

class _DeckWidgetState extends State<DeckWidget> {
  final DeckCubit cubit = DeckCubit(
    deckRepository: getIt<DeckRepository>(),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Deck List",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<DeckCubit, DeckState>(
        bloc: cubit,
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
        listener: (BuildContext context, DeckState state) {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/deck_icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.black,
                BlendMode.srcIn,
              ),
              semanticsLabel: 'Decks',
            ),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.black,
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
                _addDockRequest();
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  void _addDockRequest() {
    context.push('/createDeck').then((deckName) {
      if (deckName is String) {
        cubit.createDeck(deckName);
      }
    });
    // var deckName = '';
    // alert(
    //   context,
    //   title: const Text("Add Deck"),
    //   content: FillDeckDataWidget(
    //     onValueChange: (text) {
    //       deckName = text;
    //     },
    //   ),
    // ).then((value) {
    //   if (value ?? false) {
    //     cubit.createDeck(deckName);
    //   }
    // });
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
    var newDeckName = '';
    alert(
      context,
      title: Text(
        "Enter new name for ${deck.title}",
      ),
      content: FillDeckDataWidget(
        onValueChange: (text) {
          newDeckName = text;
        },
      ),
    ).then(
      (value) {
        if (value ?? false) {
          cubit.editDeck(deck, newDeckName);
        }
      },
    );
  }

  void _openDeck(DeckItem deck) {
    context.go("/quizCardList", extra: deck);
  }
}
