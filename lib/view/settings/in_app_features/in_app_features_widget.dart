import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_simple_header.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/settings/in_app_features/cubit/in_app_features_cubit.dart';

class SettingsInAppFeaturesWidget extends HookWidget {
  const SettingsInAppFeaturesWidget({super.key});

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
    }, []);

    final l10n = localize(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            AppSimpleHeader(
              title: l10n.inAppFeaturesTitle,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocConsumer<InAppFeaturesCubit, InAppFeaturesState>(
                bloc: cubit,
                buildWhen: (prevState, nextState) {
                  return nextState is BuilderState;
                },
                builder: (BuildContext context, state) {
                  if (state is InAppFeaturesDataState) {
                    return _InAppFeaturesContent(
                      isUnlimitedDecksCardsPurchased:
                          state.isUnlimitedDecksCardsPurchased,
                      isQuizzyAiSubscribed: state.isQuizzyAiSubscribed,
                      onPurchaseUnlimitedDecksCards:
                          cubit.purchaseUnlimitedDecksCards,
                      onSubscribeQuizzyAi: cubit.subscribeQuizzyAi,
                      onRestorePurchases: cubit.restorePurchases,
                    );
                  }
                  if (state is InAppFeaturesLoadingState ||
                      state is InAppFeaturesPurchasingState ||
                      state is InAppFeaturesRestoringState) {
                    return const SimpleLoadingWidget();
                  }
                  throw ArgumentError('Wrong state: $state');
                },
                listenWhen: (prevState, nextState) {
                  return nextState is ListenerState;
                },
                listener: (BuildContext context, InAppFeaturesState state) {
                  if (state is InAppFeaturesPurchaseSuccessState) {
                    snackBar(context,
                        message: l10n.inAppFeaturesPurchaseSuccess);
                  } else if (state is InAppFeaturesRestoreSuccessState) {
                    snackBar(context,
                        message: l10n.inAppFeaturesRestoreSuccess);
                  } else if (state is InAppFeaturesErrorState) {
                    snackBar(
                      context,
                      message: state.error,
                      duration: const Duration(seconds: 4),
                      isError: true,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InAppFeaturesContent extends StatelessWidget {
  const _InAppFeaturesContent({
    required this.isUnlimitedDecksCardsPurchased,
    required this.isQuizzyAiSubscribed,
    required this.onPurchaseUnlimitedDecksCards,
    required this.onSubscribeQuizzyAi,
    required this.onRestorePurchases,
  });

  final bool isUnlimitedDecksCardsPurchased;
  final bool isQuizzyAiSubscribed;
  final VoidCallback onPurchaseUnlimitedDecksCards;
  final VoidCallback onSubscribeQuizzyAi;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _FeatureCard(
          iconAsset: 'assets/icons/infinity.svg',
          title: l10n.inAppFeaturesUnlimitedTitle,
          description: l10n.inAppFeaturesUnlimitedDescription,
          actionTitle: l10n.inAppFeaturesPurchaseButton,
          purchasedLabel: l10n.inAppFeaturesPurchased,
          subtitle: l10n.inAppFeaturesUnlimitedSubtitle,
          isPurchased: isUnlimitedDecksCardsPurchased,
          onPurchase: onPurchaseUnlimitedDecksCards,
        ),
        const SizedBox(height: 24),
        _FeatureCard(
          iconAsset: 'assets/icons/quizzy_ai.svg',
          title: l10n.inAppFeaturesQuizzyAiTitle,
          description: l10n.inAppFeaturesQuizzyAiDescription,
          actionTitle: l10n.inAppFeaturesSubscribeButton,
          purchasedLabel: l10n.inAppFeaturesSubscribed,
          subtitle: l10n.inAppFeaturesQuizzyAiSubtitle,
          isPurchased: isQuizzyAiSubscribed,
          onPurchase: onSubscribeQuizzyAi,
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: onRestorePurchases,
          icon: const Icon(Icons.restore, color: AppColors.primary500),
          label: Text(
            l10n.inAppFeaturesRestoreButton,
            style: AppTypography.buttonMain.copyWith(
              color: AppColors.primary500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.actionTitle,
    required this.purchasedLabel,
    required this.subtitle,
    required this.isPurchased,
    required this.onPurchase,
  });

  final String iconAsset;
  final String title;
  final String description;
  final String actionTitle;
  final String purchasedLabel;
  final String subtitle;
  final bool isPurchased;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          SvgPicture.asset(
            iconAsset,
            width: 40,
            height: 40,
            colorFilter: const ColorFilter.mode(
              AppColors.primary500,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.h3.copyWith(
              color: AppColors.grayscale600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.mainText.copyWith(
              color: AppColors.grayscale500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (isPurchased)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.success100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    purchasedLabel,
                    style: AppTypography.buttonMain.copyWith(
                      color: AppColors.success600,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.grayscaleWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionTitle,
                  style: AppTypography.buttonMain.copyWith(
                    color: AppColors.grayscaleWhite,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTypography.secondaryText.copyWith(
              color: AppColors.grayscale400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}