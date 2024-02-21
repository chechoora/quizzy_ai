import 'package:flutter/material.dart';

class FillDeckDataWidget extends StatefulWidget {
  const FillDeckDataWidget({
    this.onValueChange,
    super.key,
  });

  final ValueChanged<String>? onValueChange;

  @override
  State<FillDeckDataWidget> createState() => _FillDeckDataWidgetState();
}

class _FillDeckDataWidgetState extends State<FillDeckDataWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Enter deck name",
        hintText: "Flutter",
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onValueChange,
    );
  }
}
