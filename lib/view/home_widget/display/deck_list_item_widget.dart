import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

class DeckListItemWidget extends StatelessWidget {
  const DeckListItemWidget({
    required this.deck,
    this.onDeckRemoveRequest,
    this.onDeckEditRequest,
    this.onDeckClicked,
    super.key,
  });

  final DeckItem deck;
  final ValueChanged<DeckItem>? onDeckRemoveRequest;
  final ValueChanged<DeckItem>? onDeckEditRequest;
  final ValueChanged<DeckItem>? onDeckClicked;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: AppColors.grayscaleWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: GestureDetector(
        onTap: () => onDeckClicked?.call(deck),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/folder.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  deck.title,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.grayscale600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _MoreButton(
                onEditPressed: () => onDeckEditRequest?.call(deck),
                onDeletePressed: () => onDeckRemoveRequest?.call(deck),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MenuAction { edit, delete }

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    this.onEditPressed,
    this.onDeletePressed,
  });

  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:
            onEditPressed?.call();
          case _MenuAction.delete:
            onDeletePressed?.call();
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.grayscaleWhite,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MenuAction.edit,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/edit.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit deck',
                style: AppTypography.mainText.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/delete.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete deck',
                style: AppTypography.mainText.copyWith(
                  color: AppColors.error500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(),
          const SizedBox(height: 3),
          _buildDot(),
          const SizedBox(height: 3),
          _buildDot(),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.grayscale500,
        shape: BoxShape.circle,
      ),
    );
  }
}
