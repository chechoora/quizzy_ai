import 'package:flutter/material.dart';

class CreateCardDisplay extends StatefulWidget {
  const CreateCardDisplay({super.key});

  @override
  State<CreateCardDisplay> createState() => _CreateCardDisplayState();
}

class _CreateCardDisplayState extends State<CreateCardDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Add question'),
        TextFormField(),
        const Text('Add answer'),
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
