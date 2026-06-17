import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/in_app_purchase/cubit/paywall_cubit.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';

Future<bool?> showPaywallBottomSheet(
  BuildContext context, {
  required String limitMessage,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PaywallBottomSheet(limitMessage: limitMessage),
  );
}

class _PaywallBottomSheet extends HookWidget {
  const _PaywallBottomSheet({required this.limitMessage});

  final String limitMessage;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => PaywallCubit(
        inAppPurchaseService: getIt<InAppPurchaseService>(),
      ),
    );
    useEffect(() => cubit.close, [cubit]);

    final errorMessage = useState<String?>(null);
    final l10n = localize(context);

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
                      l10n.inAppFeaturesUnlimitedTitle,
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
                        'assets/icons/infinity.svg',
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
                      l10n.inAppFeaturesUnlimitedDescription,
                      style: AppTypography.secondaryText.copyWith(
                        color: AppColors.grayscale500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.inAppFeaturesUnlimitedSubtitle,
                      style: AppTypography.secondaryText.copyWith(
                        color: AppColors.grayscale400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      AppButton.primary(
                        text: l10n.inAppFeaturesPurchaseButton,
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
                    const SizedBox(height: 16),
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
