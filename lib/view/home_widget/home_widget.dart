import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/backup_scheduler.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_restore_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/onboarding/onboarding_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/view/in_app_purchase/paywall_bottom_sheet.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/home_widget/cubit/deck_cubit.dart';
import 'package:poc_ai_quiz/view/home_widget/display/deck_list_display_widget.dart';
import 'package:poc_ai_quiz/view/onboarding/onboarding_bottom_sheet.dart';
import 'package:poc_ai_quiz/view/onboarding/onboarding_paywall_bottom_sheet.dart';
import 'package:poc_ai_quiz/view/settings/settings_widget.dart';
import 'package:poc_ai_quiz/view/widgets/sync_progress_bar.dart';

class HomeWidget extends HookWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => HomeCubit(
        deckRepository: getIt<DeckRepository>(),
        deckPremiumManager: getIt<DeckPremiumManager>(),
        onboardingService: getIt<OnboardingService>(),
        iCloudRestoreService: getIt<ICloudRestoreService>(),
        backupScheduler: getIt<BackupScheduler>(),
        isSubscriptionOnly: getIt<AppConfig>().isSubscriptionOnly,
      ),
    );
    final selectedIndex = useState(0);

    useEffect(() {
      cubit.watchDecks();
      cubit.checkOnboarding();
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

    void startOnboardingFlow() async {
      if (getIt<AppConfig>().flavor == Flavor.quizzyPro) {
        await context.push(OnboardingProRoute().path);
      } else {
        await showOnboardingBottomSheet(context);
      }
      if (!context.mounted) return;
      await showOnboardingPaywallBottomSheet(context);
      await cubit.completeOnboarding();
      cubit.checkICloudRestore();
    }

    Future<void> showCreateDeckPremiumError() async {
      final purchased = await showPaywallBottomSheet(
        context,
        limitMessage: localize(context).homePremiumDeckLimitMessage,
        feature: cubit.unlockFeature,
        trigger: 'deck_limit',
        limitType: 'deck',
      );
      if (purchased == true && context.mounted) {
        cubit.addDockRequest();
      }
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
              return Column(
                children: [
                  Expanded(
                    child: deckList.isEmpty
                        ? EmptyListWidget(
                            imageAsset: 'assets/images/decks_empty_state.png',
                            title: localize(context).homeEmptyStateTitle,
                            description:
                                localize(context).homeEmptyStateDescription,
                          )
                        : DeckListDisplayWidget(
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
                          ),
                  ),
                  if (getIt<AppConfig>().backendSupported)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AppButton.secondary(
                        text: localize(context).homePublicDecksButton,
                        onPressed: () =>
                            context.push(PublicDecksRoute().path),
                      ),
                    ),
                ],
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
          if (state is DeckCreatedState) {
            openDeck(state.deck);
          } else if (state is RequestCreateDeckState) {
            if (state.canCreateDeck) {
              addDockRequest();
            } else {
              showCreateDeckPremiumError();
            }
          } else if (state is ShowOnboardingState) {
            startOnboardingFlow();
          } else if (state is ShowICloudRestoreState) {
            _offerICloudRestore(context, cubit);
          } else if (state is ICloudRestoreSuccessState) {
            snackBar(
              context,
              message: localize(context)
                  .importExportICloudRestoreSuccess(state.deckCount),
            );
          } else if (state is ICloudRestoreLimitState) {
            final typeName = state.exception.type == ImportExportType.card
                ? localize(context).card
                : localize(context).deck;
            showPaywallBottomSheet(
              context,
              limitMessage: localize(context)
                  .importLimitExceeded(state.exception.limit, typeName),
              feature: InAppPurchaseFeature.unlimitedDecksCards,
              trigger: 'icloud_restore_limit',
              limitType: state.exception.type.name,
            );
          } else if (state is ICloudRestoreErrorState) {
            snackBar(
              context,
              message: localize(context).importExportError,
              isError: true,
            );
          }
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SyncProgressBar(),
          Container(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the one-time clean-install restore dialog. The decision to offer it
/// (and the flag persistence) lives in [HomeCubit]/`ICloudRestoreService`; this
/// only renders the dialog and hands the choice back to the cubit.
Future<void> _offerICloudRestore(BuildContext context, HomeCubit cubit) async {
  final l10n = localize(context);
  final restore = await alert(
    context,
    title: Text(
      l10n.cleanInstallRestoreTitle,
      style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
    ),
    content: Text(
      l10n.cleanInstallRestoreMessage,
      style: AppTypography.h4.copyWith(color: AppColors.grayscale600),
    ),
    primary: AppDialogButton.primary(
      text: l10n.cleanInstallRestoreButton,
      onPressed: () => Navigator.of(context).pop(true),
    ),
    secondary: AppDialogButton.destructive(
      text: l10n.cleanInstallSkipButton,
      onPressed: () => Navigator.of(context).pop(false),
    ),
  );

  if (restore == true) {
    cubit.restoreFromICloud();
  } else {
    cubit.skipICloudRestore();
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
