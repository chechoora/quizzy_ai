import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/settings/in_app_features/cubit/in_app_features_cubit.dart';
import 'package:poc_ai_quiz/view/widgets/feature_purchase_card.dart';

Future<void> showOnboardingPaywallBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _OnboardingPaywallBottomSheet(),
  );
}

class _OnboardingPaywallBottomSheet extends HookWidget {
  const _OnboardingPaywallBottomSheet();

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => InAppFeaturesCubit(
        inAppPurchaseService: getIt<InAppPurchaseService>(),
      ),
    );
    useEffect(() {
      cubit.loadFeatures();
      return cubit.close;
    }, [cubit]);

    final errorMessage = useState<String?>(null);
    final l10n = localize(context);

    return BlocConsumer<InAppFeaturesCubit, InAppFeaturesState>(
      bloc: cubit,
      buildWhen: (_, state) => state is BuilderState,
      listenWhen: (_, state) =>
          state is ListenerState || state is InAppFeaturesDataState,
      listener: (context, state) {
        if (state is InAppFeaturesErrorState) {
          errorMessage.value = l10n.inAppFeaturesPurchaseError;
        } else if (state is InAppFeaturesDataState &&
            state.isUnlimitedDecksCardsPurchased &&
            state.isQuizzyAiSubscribed) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      l10n.onboardingPaywallTitle,
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
              Container(
                color: AppColors.backgroundSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: state is InAppFeaturesDataState
                    ? _PaywallContent(
                        state: state,
                        errorMessage: errorMessage.value,
                        onPurchaseUnlimitedDecksCards: () {
                          errorMessage.value = null;
                          cubit.purchaseUnlimitedDecksCards();
                        },
                        onSubscribeQuizzyAi: () {
                          errorMessage.value = null;
                          cubit.subscribeQuizzyAi();
                        },
                        onRestorePurchases: () {
                          errorMessage.value = null;
                          cubit.restorePurchases();
                        },
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaywallContent extends StatelessWidget {
  const _PaywallContent({
    required this.state,
    required this.errorMessage,
    required this.onPurchaseUnlimitedDecksCards,
    required this.onSubscribeQuizzyAi,
    required this.onRestorePurchases,
  });

  final InAppFeaturesDataState state;
  final String? errorMessage;
  final VoidCallback onPurchaseUnlimitedDecksCards;
  final VoidCallback onSubscribeQuizzyAi;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.onboardingPaywallIntro,
          style: AppTypography.mainText.copyWith(
            color: AppColors.grayscale500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FeaturePurchaseCard(
          iconAsset: 'assets/icons/infinity.svg',
          title: l10n.inAppFeaturesUnlimitedTitle,
          description: l10n.inAppFeaturesUnlimitedDescription,
          actionTitle: l10n.inAppFeaturesPurchaseButton,
          purchasedLabel: l10n.inAppFeaturesPurchased,
          subtitle: l10n.inAppFeaturesUnlimitedSubtitle,
          isPurchased: state.isUnlimitedDecksCardsPurchased,
          onPurchase: onPurchaseUnlimitedDecksCards,
        ),
        const SizedBox(height: 16),
        FeaturePurchaseCard(
          iconAsset: 'assets/icons/quizzy_ai.svg',
          title: l10n.inAppFeaturesQuizzyAiTitle,
          description: l10n.inAppFeaturesQuizzyAiDescription,
          actionTitle: l10n.inAppFeaturesSubscribeButton,
          purchasedLabel: l10n.inAppFeaturesSubscribed,
          subtitle: l10n.inAppFeaturesQuizzyAiSubtitle,
          isPurchased: state.isQuizzyAiSubscribed,
          onPurchase: onSubscribeQuizzyAi,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: AppTypography.secondaryText.copyWith(
              color: AppColors.error500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: onRestorePurchases,
            child: Text(
              l10n.inAppFeaturesRestoreButton,
              style: AppTypography.secondaryText.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
