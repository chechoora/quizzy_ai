import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

class AppTextField extends HookWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.trailingActionText,
    this.onTrailingActionPressed,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? trailingActionText;
  final VoidCallback? onTrailingActionPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final TextCapitalization textCapitalization;

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
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        obscureText: obscureText,
        style: AppTypography.mainText.copyWith(
          color: AppColors.grayscale600,
        ),
        cursorColor: AppColors.primary500,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.mainText.copyWith(
            color: AppColors.grayscale300,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: trailingActionText != null
              ? _TrailingAction(
                  text: trailingActionText!,
                  onPressed: onTrailingActionPressed,
                )
              : null,
        ),
      ),
    );
  }
}

class _TrailingAction extends StatelessWidget {
  const _TrailingAction({
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: AppTypography.buttonSmall.copyWith(
            color: AppColors.primary500,
          ),
        ),
      ),
    );
  }
}
