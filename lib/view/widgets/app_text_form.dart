import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

class AppTextForm extends HookWidget {
  const AppTextForm({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    this.keyboardType,
    this.minLines = 4,
    this.maxLines,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final effectiveFocusNode = focusNode ?? useFocusNode();
    final isFocused = useState(false);

    useEffect(() {
      void onFocusChange() {
        isFocused.value = effectiveFocusNode.hasFocus;
      }

      effectiveFocusNode.addListener(onFocusChange);
      return () => effectiveFocusNode.removeListener(onFocusChange);
    }, [effectiveFocusNode]);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(15),
        border: isFocused.value
            ? Border.all(color: AppColors.primary500, width: 2)
            : null,
        boxShadow: isFocused.value
            ? [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.3),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: effectiveFocusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        keyboardType: keyboardType ?? TextInputType.multiline,
        minLines: minLines,
        maxLines: maxLines,
        textAlignVertical: TextAlignVertical.top,
        style: AppTypography.mainText.copyWith(
          color: AppColors.grayscale600,
        ),
        cursorColor: AppColors.primary500,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: AppTypography.mainText.copyWith(
            color: AppColors.grayscale300,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
