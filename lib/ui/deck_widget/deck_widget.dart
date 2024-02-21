import 'package:alert_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/ui/deck_widget/cubit/deck_cubit.dart';
import 'package:poc_ai_quiz/ui/deck_widget/deck_list_display_widget.dart';
import 'package:poc_ai_quiz/ui/deck_widget/fill_deck_data_widget.dart';
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';

class DeckWidget extends StatefulWidget {
  const DeckWidget({super.key});

  @override
  State<DeckWidget> createState() => _DeckWidgetState();
}

class _DeckWidgetState extends State<DeckWidget> {
  final DeckCubit cubit = DeckCubit(
    deckRepository: getIt<DeckRepository>(),
  );

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
            return DeckListDisplayWidget(
              deckList: state.deckList,
            );
          }
          if (state is DeckLoadingState) {
            return const SimpleLoadingWidget();
          }
          throw ArgumentError('Wrong state');
        },
        listener: (BuildContext context, DeckState state) {},
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Deck',
        onPressed: () {
          _addDockRequest();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _addDockRequest() {
    var deckName = '';
    alert(
      context,
      title: const Text("Add Deck"),
      content: FillDeckDataWidget(
        onValueChange: (text) {
          deckName = text;
        },
      ),
    ).then((value) {
      cubit.createDeck(deckName);
    });
  }
}
