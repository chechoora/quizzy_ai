import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/widgets/feature_purchase_card.dart';
import 'package:poc_ai_quiz/view/settings/in_app_features/cubit/in_app_features_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsInAppFeaturesWidget extends HookWidget {
  const SettingsInAppFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => InAppFeaturesCubit(
        inAppPurchaseService: getIt<InAppPurchaseService>(),
        settingsService: getIt<SettingsService>(),
        isSubscriptionOnly: getIt<AppConfig>().isSubscriptionOnly,
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
                      state: state,
                      onPurchase: cubit.purchase,
                      onRestorePurchases: cubit.restorePurchases,
                      onSelectOption: cubit.selectOption,
                      onManageSubscription: cubit.manageSubscription,
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
                  } else if (state is InAppFeaturesOpenUrlState) {
                    _launchUrl(context, state.url);
                  } else if (state is InAppFeaturesErrorState) {
                    snackBar(
                      context,
                      message: l10n.inAppFeaturesPurchaseError,
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

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        final l10n = localize(context);
        snackBar(
          context,
          message: l10n.settingsAiValidatorCouldNotOpenUrlError(url),
          isError: true,
        );
      }
    }
  }
}

class _InAppFeaturesContent extends StatelessWidget {
  const _InAppFeaturesContent({
    required this.state,
    required this.onPurchase,
    required this.onRestorePurchases,
    required this.onSelectOption,
    required this.onManageSubscription,
  });

  final InAppFeaturesDataState state;
  final VoidCallback onPurchase;
  final VoidCallback onRestorePurchases;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onManageSubscription;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (state is InAppFeaturesFullUnlockState)
          FeaturePurchaseCard(
            iconAsset: 'assets/icons/infinity.svg',
            title: l10n.inAppFeaturesUnlimitedTitle,
            description: l10n.inAppFeaturesUnlimitedDescription,
            actionTitle: l10n.inAppFeaturesPurchaseButton,
            purchasedLabel: l10n.inAppFeaturesPurchased,
            subtitle: l10n.inAppFeaturesUnlimitedSubtitle,
            isPurchased:
                (state as InAppFeaturesFullUnlockState).isPurchased,
            onPurchase: onPurchase,
          )
        else if (state is InAppFeaturesQuizzyAiState)
          FeaturePurchaseCard(
            iconAsset: 'assets/icons/quizzy_ai.svg',
            title: l10n.inAppFeaturesQuizzyAiTitle,
            description: l10n.inAppFeaturesQuizzyAiDescription,
            actionTitle: l10n.inAppFeaturesSubscribeButton,
            purchasedLabel: l10n.inAppFeaturesSubscribed,
            subtitle: l10n.inAppFeaturesQuizzyAiSubtitle,
            isPurchased: (state as InAppFeaturesQuizzyAiState).isSubscribed,
            onPurchase: onPurchase,
            purchaseOptions: (state as InAppFeaturesQuizzyAiState).options,
            selectedPackageIdentifier:
                (state as InAppFeaturesQuizzyAiState).selectedPackageIdentifier,
            onSelectOption: onSelectOption,
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
        if (state is InAppFeaturesQuizzyAiState &&
            (state as InAppFeaturesQuizzyAiState).isSubscribed)
          TextButton.icon(
            onPressed: onManageSubscription,
            icon: const Icon(Icons.settings, color: AppColors.primary500),
            label: Text(
              l10n.inAppFeaturesManageSubscriptionButton,
              style: AppTypography.buttonMain.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ),
      ],
    );
  }
}

