import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';

class SimpleLoadingWidget extends StatelessWidget {
  const SimpleLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: const SpinKitSpinningLines(
        size: 32,
        color: AppColors.primary500,
        duration: Duration(milliseconds: 5000),
      ),
    );
  }
}
