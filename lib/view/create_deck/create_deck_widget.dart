import 'package:flutter/material.dart';

import 'display/create_deck_display_widget.dart';

class CreateDeckWidget extends StatefulWidget {
  const CreateDeckWidget({super.key});

  @override
  State<CreateDeckWidget> createState() => _CreateDeckWidgetState();
}

class _CreateDeckWidgetState extends State<CreateDeckWidget> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateDeckDisplay(),
    );
  }
}
