import 'package:flutter/material.dart';

class PocWidget extends StatefulWidget {
  const PocWidget({super.key});

  @override
  State<PocWidget> createState() => _PocWidgetState();
}

class _PocWidgetState extends State<PocWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Text fields allow users to type text into an app. '
            'They are used to build forms, send messages, '
            'create search experiences, and more.'),
        SizedBox(
          height: 200,
          child: Align(
            alignment: Alignment.topLeft,
            child: TextField(
              maxLines: null,
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type similar answer',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
