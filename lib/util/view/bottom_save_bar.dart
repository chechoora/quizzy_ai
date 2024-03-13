import 'package:flutter/material.dart';

class BottomSaveBar extends StatelessWidget {
  const BottomSaveBar({
    this.onBackRequest,
    this.onSaveRequest,
    super.key,
  });

  final VoidCallback? onBackRequest;
  final VoidCallback? onSaveRequest;

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
            tooltip: 'Save',
            icon: Icon(
              Icons.save,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onSaveRequest,
          ),
        ],
      ),
    );
  }
}
