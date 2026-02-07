import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/user/user_quota_repository.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/quota/quota_cubit.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';

class QuotaDisplayWidget extends HookWidget {
  const QuotaDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userQuotaRepository = getIt<UserQuotaRepository>();
    final inAppPurchaseService = getIt<InAppPurchaseService>();

    final cubit = useMemoized(
      () => QuotaCubit(
        repository: userQuotaRepository,
        inAppPurchaseService: inAppPurchaseService,
      ),
    );

    useEffect(() {
      cubit.loadQuota();
      return cubit.close;
    }, []);

    final l10n = localize(context);

    return BlocBuilder<QuotaCubit, QuotaState>(
      bloc: cubit,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsAiValidatorQuotaTitle,
              style: AppTypography.h4.copyWith(
                color: AppColors.grayscale600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grayscaleWhite,
                borderRadius: BorderRadius.circular(15),
              ),
              child: switch (state) {
                QuotaLoadingState() => const Center(
                    child: SimpleLoadingWidget(),
                  ),
                QuotaDataState() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.settingsAiValidatorWeeklyUsageLabel,
                              style: AppTypography.mainText.copyWith(
                                color: AppColors.grayscale500,
                              ),
                            ),
                          ),
                          Text(
                            '${state.quota.weeklyPercentUsage.toStringAsFixed(1)}%',
                            style: AppTypography.h4.copyWith(
                              color: AppColors.grayscale600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.quota.weeklyPercentUsage / 100,
                          backgroundColor: AppColors.grayscale200,
                          color: state.quota.weeklyPercentUsage > 80
                              ? AppColors.error500
                              : AppColors.primary500,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.settingsAiValidatorQuestionsLeftLabel,
                              style: AppTypography.mainText.copyWith(
                                color: AppColors.grayscale500,
                              ),
                            ),
                          ),
                          Text(
                            '${state.quota.questionsLeft}',
                            style: AppTypography.h4.copyWith(
                              color: AppColors.grayscale600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                QuotaErrorState() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.error,
                        style: AppTypography.mainText.copyWith(
                          color: AppColors.error500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton.primary(
                        text: 'Retry',
                        onPressed: () => cubit.loadQuota(),
                      ),
                    ],
                  ),
              },
            ),
          ],
        );
      },
    );
  }
}
