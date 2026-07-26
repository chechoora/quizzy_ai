import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/purchase_option.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/in_app_purchase/cubit/paywall_cubit.dart';
import 'package:poc_ai_quiz/view/widgets/purchase_options_row.dart';

Future<bool?> showPaywallBottomSheet(
  BuildContext context, {
  required String limitMessage,
  required InAppPurchaseFeature feature,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PaywallBottomSheet(
      limitMessage: limitMessage,
      feature: feature,
    ),
  );
}

class _PaywallBottomSheet extends HookWidget {
  const _PaywallBottomSheet({
    required this.limitMessage,
    required this.feature,
  });

  final String limitMessage;
  final InAppPurchaseFeature feature;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => PaywallCubit(
        inAppPurchaseService: getIt<InAppPurchaseService>(),
        analyticsService: getIt<AnalyticsService>(),
        feature: feature,
      ),
    );
    final errorMessage = useState<String?>(null);
    final l10n = localize(context);
    final isSubscription = feature == InAppPurchaseFeature.quizzyAi;
    final iconAsset = isSubscription
        ? 'assets/icons/quizzy_ai.svg'
        : 'assets/icons/infinity.svg';
    final title = isSubscription
        ? l10n.inAppFeaturesQuizzyAiTitle
        : l10n.inAppFeaturesUnlimitedTitle;
    final description = isSubscription
        ? l10n.inAppFeaturesQuizzyAiDescription
        : l10n.inAppFeaturesUnlimitedDescription;
    final actionTitle = isSubscription
        ? l10n.inAppFeaturesSubscribeButton
        : l10n.inAppFeaturesPurchaseButton;

    return BlocConsumer<PaywallCubit, PaywallState>(
      bloc: cubit,
      buildWhen: (_, state) => state is BuilderState,
      listenWhen: (_, state) => state is ListenerState,
      listener: (context, state) {
        if (state is PaywallPurchaseSuccessState ||
            state is PaywallRestoreSuccessState) {
          Navigator.pop(context, true);
        } else if (state is PaywallErrorState) {
          errorMessage.value = l10n.inAppFeaturesPurchaseError;
        }
      },
      builder: (context, state) {
        final isLoading = state is PaywallLoadingState;
        final options = state is PaywallOptionsState
            ? state.options
            : const <PurchaseOption>[];
        final selectedPackageIdentifier = state is PaywallOptionsState
            ? state.selectedPackageIdentifier
            : null;

        return SafeArea(
          top: false,
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
                      title,
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
                      textAlign: TextAlign.center,
                      limitMessage,
                      style: AppTypography.mainText.copyWith(
                        color: AppColors.grayscale500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SvgPicture.asset(
                        iconAsset,
                        width: 48,
                        height: 48,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTypography.secondaryText.copyWith(
                        color: AppColors.grayscale500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (isSubscription && options.isNotEmpty)
                      PurchaseOptionsRow(
                        options: options,
                        selectedPackageIdentifier: selectedPackageIdentifier,
                        onSelected: cubit.selectOption,
                      ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      AppButton.primary(
                        text: actionTitle,
                        onPressed: () {
                          errorMessage.value = null;
                          cubit.purchase();
                        },
                      ),
                    if (errorMessage.value != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage.value!,
                        style: AppTypography.secondaryText.copyWith(
                          color: AppColors.error500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                errorMessage.value = null;
                                cubit.restore();
                              },
                        child: Text(
                          l10n.inAppFeaturesRestoreButton,
                          style: AppTypography.secondaryText.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
