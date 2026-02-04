import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:poc_ai_quiz/util/view/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/home_widget/cubit/deck_cubit.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_display_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_widget.dart';
import 'package:poc_ai_quiz/view/widgets/app_add_button.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final HomeCubit cubit = HomeCubit(
    deckRepository: getIt<DeckRepository>(),
    deckPremiumManager: getIt<DeckPremiumManager>(),
  );

  int _selectedIndex = 0;

  @override
  void initState() {
    cubit.fetchDecks();
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeCubit, DeckState>(
        bloc: cubit,
        buildWhen: (prevState, nextState) {
          return nextState is BuilderState;
        },
        builder: (BuildContext context, state) {
          if (state is DeckDataState) {
            if (_selectedIndex == 0) {
              return DeckListDisplayWidget(
                deckList: state.deckList,
                onDeckRemoveRequest: (deck) {
                  _launchConfirmDeleteRequest(deck);
                },
                onDeckEditRequest: (deck) {
                  _launchEditDeckTitleRequest(deck);
                },
                onDeckClicked: (deck) {
                  _openDeck(deck);
                },
              );
            } else if (_selectedIndex == 1) {
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
              _addDockRequest();
            } else {
              _showCreateDeckPremiumError();
            }
          }
        },
      ),
      bottomNavigationBar: Container(
        height: 84,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: SvgPicture.asset(
                'assets/icons/decks.svg',
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0
                      ? AppColors.primary500
                      : AppColors.grayscale500,
                  BlendMode.srcIn,
                ),
                semanticsLabel: localize(context).homeDecksLabel,
              ),
              label: localize(context).homeDecksLabel,
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            AppAddButton(
              onPressed: () => cubit.addDockRequest(),
            ),
            _NavItem(
              icon: SvgPicture.asset(
                'assets/icons/settings.svg',
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1
                      ? AppColors.primary500
                      : AppColors.grayscale500,
                  BlendMode.srcIn,
                ),
                semanticsLabel: localize(context).homeDecksLabel,
              ),
              label: localize(context).homeSettingsLabel,
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  void _addDockRequest() {
    context.push(CreateDeckRoute().path).then((deckName) {
      if (deckName is String) {
        cubit.createDeck(deckName);
      }
    });
  }

  void _launchConfirmDeleteRequest(DeckItem deck) {
    alert(
      context,
      content: Text(
        localize(context).homeDeleteDeckConfirmation(deck.title),
      ),
    ).then(
      (value) {
        if (value ?? false) {
          cubit.deleteDeck(deck);
        }
      },
    );
  }

  void _launchEditDeckTitleRequest(DeckItem deck) {
    context.push(CreateDeckRoute().path, extra: deck.title).then(
      (deckName) {
        if (deckName is String) {
          cubit.editDeck(deck, deckName);
        }
      },
    );
  }

  void _openDeck(DeckItem deck) {
    context.push(QuizCardListRoute().path, extra: deck);
  }

  void _showCreateDeckPremiumError() {
    alert(
      context,
      content: Text(
        localize(context).homePremiumDeckLimitMessage,
      ),
      textCancel: const SizedBox.shrink(),
      //textOK: Text(localize(context).homeUnlockButton),
    ).then(
      (value) {
        if (value ?? false) {
          // TODO Navigate to purchase screen
        }
      },
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
