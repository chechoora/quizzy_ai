import 'package:flutter/material.dart';

class CreateDeckDisplay extends StatefulWidget {
  const CreateDeckDisplay({super.key});

  @override
  State<CreateDeckDisplay> createState() => _CreateDeckDisplayState();
}

class _CreateDeckDisplayState extends State<CreateDeckDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Title of the deck'),
        TextFormField(),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
