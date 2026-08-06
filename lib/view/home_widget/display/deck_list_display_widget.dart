import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_item_widget.dart';

class DeckListDisplayWidget extends StatelessWidget {
  const DeckListDisplayWidget({
    required this.deckList,
    this.onDeckRemoveRequest,
    this.onDeckEditRequest,
    this.onDeckClicked,
    super.key,
  });

  final List<DeckItem> deckList;
  final ValueChanged<DeckItem>? onDeckRemoveRequest;
  final ValueChanged<DeckItem>? onDeckEditRequest;
  final ValueChanged<DeckItem>? onDeckClicked;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final appConfig = getIt.get<AppConfig>();
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(
            height: 32,
          ),
          Text(
            appConfig.backendSupported ? l10n.appTitlePro : l10n.appTitle,
            style: AppTypography.h1.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final deck = deckList[index];
                return DeckListItemWidget(
                  title: deck.title,
                  cardCount: deck.cardCount,
                  onTap: () => onDeckClicked?.call(deck),
                  trailing: AppMoreButton(
                    actions: [
                      AppMoreButtonAction(
                        label: l10n.homeEditDeckAction,
                        icon: 'assets/icons/edit.svg',
                        onPressed: () => onDeckEditRequest?.call(deck),
                      ),
                      AppMoreButtonAction(
                        label: l10n.homeDeleteDeckAction,
                        icon: 'assets/icons/delete.svg',
                        textColor: AppColors.error500,
                        onPressed: () => onDeckRemoveRequest?.call(deck),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemCount: deckList.length,
            ),
          ),
        ],
      ),
    );
  }
}
