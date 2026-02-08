import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/home_widget/cubit/deck_cubit.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_display_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_widget.dart';
import 'package:poc_ai_quiz/view/widgets/app_add_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_dialog_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_text_field.dart';

class HomeWidget extends HookWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => HomeCubit(
        deckRepository: getIt<DeckRepository>(),
        deckPremiumManager: getIt<DeckPremiumManager>(),
      ),
    );
    final selectedIndex = useState(0);

    useEffect(() {
      cubit.watchDecks();
      return cubit.close;
    }, [cubit]);

    Future<String?> showCreateDeckBottomSheet({String? deckName}) {
      return showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _CreateDeckBottomSheet(deckName: deckName),
      );
    }

    void addDockRequest() {
      showCreateDeckBottomSheet().then((deckName) {
        if (deckName is String && deckName.isNotEmpty) {
          cubit.createDeck(deckName);
        }
      });
    }

    void launchConfirmDeleteRequest(DeckItem deck) {
      alert(
        context,
        content: Text(
          localize(context).homeDeleteDeckConfirmation(deck.title),
          style: AppTypography.h4.copyWith(
            color: AppColors.grayscale600,
          ),
        ),
        primary: AppDialogButton.primary(
          text: localize(context).homeCancelButton,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        secondary: AppDialogButton.destructive(
          text: localize(context).homeDeleteButton,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ).then(
        (value) {
          if (value ?? false) {
            cubit.deleteDeck(deck);
          }
        },
      );
    }

    void launchEditDeckTitleRequest(DeckItem deck) {
      showCreateDeckBottomSheet(deckName: deck.title).then(
        (deckName) {
          if (deckName is String && deckName.isNotEmpty) {
            cubit.editDeck(deck, deckName);
          }
        },
      );
    }

    void openDeck(DeckItem deck) {
      context.push(QuizCardListRoute().path, extra: deck);
    }

    void showCreateDeckPremiumError() {
      snackBar(
        context,
        message: localize(context).homePremiumDeckLimitMessage,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<HomeCubit, DeckState>(
        bloc: cubit,
        buildWhen: (prevState, nextState) {
          return nextState is BuilderState;
        },
        builder: (BuildContext context, state) {
          if (state is DeckDataState) {
            if (selectedIndex.value == 0) {
              final deckList = state.deckList;
              if (deckList.isEmpty) {
                return const _EmptyListWidget();
              }
              return DeckListDisplayWidget(
                deckList: state.deckList,
                onDeckRemoveRequest: (deck) {
                  launchConfirmDeleteRequest(deck);
                },
                onDeckEditRequest: (deck) {
                  launchEditDeckTitleRequest(deck);
                },
                onDeckClicked: (deck) {
                  openDeck(deck);
                },
              );
            } else if (selectedIndex.value == 1) {
              return const SettingsWidget();
            }
            throw ArgumentError('Wrong index');
          }
          if (state is DeckLoadingState) {
            return const SimpleLoadingWidget();
          }
          throw ArgumentError('Wrong state');
        },
        listenWhen: (prevState, nextState) {
          return nextState is ListenerState;
        },
        listener: (BuildContext context, DeckState state) {
          if (state is RequestCreateDeckState) {
            if (state.canCreateDeck) {
              addDockRequest();
            } else {
              showCreateDeckPremiumError();
            }
          }
        },
      ),
      bottomNavigationBar: Container(
        height: 84 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: SvgPicture.asset(
                      'assets/icons/decks.svg',
                      colorFilter: ColorFilter.mode(
                        selectedIndex.value == 0
                            ? AppColors.primary500
                            : AppColors.grayscale500,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: localize(context).homeDecksLabel,
                    ),
                    label: localize(context).homeDecksLabel,
                    isSelected: selectedIndex.value == 0,
                    onTap: () => selectedIndex.value = 0,
                  ),
                  AppAddButton(
                    onPressed: () => cubit.addDockRequest(),
                  ),
                  _NavItem(
                    icon: SvgPicture.asset(
                      'assets/icons/settings.svg',
                      colorFilter: ColorFilter.mode(
                        selectedIndex.value == 1
                            ? AppColors.primary500
                            : AppColors.grayscale500,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: localize(context).homeDecksLabel,
                    ),
                    label: localize(context).homeSettingsLabel,
                    isSelected: selectedIndex.value == 1,
                    onTap: () => selectedIndex.value = 1,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }
}

class _EmptyListWidget extends StatelessWidget {
  const _EmptyListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
        horizontal: 52,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/decks_empty_state.png',
            height: 148,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 24),
          Text(
            localize(context).homeEmptyStateTitle,
            style: AppTypography.h3.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localize(context).homeEmptyStateDescription,
            textAlign: TextAlign.center,
            style: AppTypography.h4.copyWith(
              color: AppColors.grayscale500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected ? AppColors.primary500 : AppColors.grayscale500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateDeckBottomSheet extends HookWidget {
  const _CreateDeckBottomSheet({this.deckName});

  final String? deckName;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: deckName);
    useListenable(controller);
    final text = controller.text.trim();
    final isEditing = deckName != null;
    final l10n = localize(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? l10n.homeEditDeckTitle : l10n.homeNewDeckTitle,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.grayscale600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.grayscale300,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing
                      ? l10n.homeEditDeckDescription
                      : l10n.homeNewDeckDescription,
                  style: AppTypography.mainText.copyWith(
                    color: AppColors.grayscale500,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller,
                  autofocus: true,
                  hint: l10n.homeNewDeckHint,
                ),
                const SizedBox(height: 20),
                AppButton.primary(
                  text: isEditing
                      ? l10n.homeSaveDeckButton
                      : l10n.homeCreateDeckButton,
                  onPressed: text.isNotEmpty
                      ? () {
                          Navigator.pop(context, text);
                        }
                      : null,
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
