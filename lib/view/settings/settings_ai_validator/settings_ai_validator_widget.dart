import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/cubit/settings_cubit.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_config_content.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_type_ui_data.dart';

class SettingsAIValidatorWidget extends HookWidget {
  const SettingsAIValidatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => SettingsAIValidatorCubit(
        settingsService: getIt<SettingsService>(),
        validatorsManager: getIt<ValidatorsManager>(),
        userRepository: getIt<UserRepository>(),
        userSettingsRepository: getIt<UserSettingsRepository>(),
      ),
    );

    useEffect(() {
      cubit.loadSettings();
      return cubit.close;
    }, []);

    void handleValidatorChange(AnswerValidatorType? newValidator) {
      if (newValidator != null) {
        cubit.updateValidator(newValidator);
      }
    }

    void handleApiKeyConfigUpdate(
        AnswerValidatorType type, ApiKeyConfig? config) {
      cubit.updateApiKeyConfig(type, config);
    }

    void handleOpenSourceConfigUpdate(
      AnswerValidatorType type,
      OpenSourceConfig? config,
    ) {
      cubit.updateOpenSourceConfig(type, config);
    }

    final l10n = localize(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            AppSimpleHeader(
              title: l10n.settingsAiValidatorTitle,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocConsumer<SettingsAIValidatorCubit, SettingsState>(
                bloc: cubit,
                buildWhen: (prevState, nextState) {
                  return nextState is BuilderState;
                },
                builder: (BuildContext context, state) {
                  if (state is SettingsDataState) {
                    return ValidatorConfigContent(
                      selectedValidator: state.validatorType,
                      validators: state.validators,
                      sectionLabel: l10n.settingsAiValidatorLabel,
                      sectionSubtitle: l10n.settingsAiValidatorSubtitle,
                      dropdownLabel: l10n.answerValidatorDropdownLabel,
                      onValidatorChanged: handleValidatorChange,
                      onApiKeyConfigUpdate: handleApiKeyConfigUpdate,
                      onOpenSourceConfigUpdate: handleOpenSourceConfigUpdate,
                    );
                  }
                  if (state is SettingsLoadingState) {
                    return const SimpleLoadingWidget();
                  }
                  throw ArgumentError('Wrong state: $state');
                },
                listenWhen: (prevState, nextState) {
                  return nextState is ListenerState;
                },
                listener: (BuildContext context, SettingsState state) {
                  if (state is SettingsUpdateSuccessState) {
                    snackBar(
                      context,
                      message: l10n.settingsAiValidatorChangedMessage(
                        state.validatorType.displayName(l10n),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  } else if (state is SettingsApiKeyUpdatedState) {
                    snackBar(
                      context,
                      message: l10n.settingsAiValidatorApiKeySavedMessage(
                        state.validatorType.displayName(l10n),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  } else if (state is SettingsErrorState) {
                    snackBar(
                      context,
                      message: state.isConfigUpdateFailure
                          ? l10n.settingsConfigUpdateFailedMessage(
                              state.error)
                          : state.error,
                      isError: true,
                      duration: const Duration(seconds: 2),
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
