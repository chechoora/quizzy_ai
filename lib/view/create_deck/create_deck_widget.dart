import 'package:flutter/material.dart';

import 'display/create_deck_display_widget.dart';

class CreateDeckWidget extends StatelessWidget {
  const CreateDeckWidget({
    this.deckName,
    super.key,
  });

  final String? deckName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CreateDeckDisplay(
          deckName: deckName,
        ),
      ),
    );
  }
}
