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
import 'package:poc_ai_quiz/view/settings/settings_deck_generation/cubit/settings_deck_generation_cubit.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_config_content.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_type_ui_data.dart';

class SettingsDeckGenerationWidget extends HookWidget {
  const SettingsDeckGenerationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => DeckGenerationCubit(
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

    void handleTypeChange(AnswerValidatorType? newType) {
      if (newType != null) {
        cubit.updateType(newType);
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
              title: l10n.settingsDeckGenerationTitle,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocConsumer<DeckGenerationCubit, DeckGenerationState>(
                bloc: cubit,
                buildWhen: (prevState, nextState) => nextState is BuilderState,
                builder: (BuildContext context, state) {
                  if (state is DeckGenerationDataState) {
                    return ValidatorConfigContent(
                      selectedValidator: state.selectedType,
                      validators: state.providers,
                      sectionLabel: l10n.settingsDeckGenerationLabel,
                      sectionSubtitle: l10n.settingsDeckGenerationSubtitle,
                      dropdownLabel: l10n.settingsDeckGenerationDropdownLabel,
                      bottomSheetTitle:
                          l10n.settingsDeckGenerationDropdownLabel,
                      onValidatorChanged: handleTypeChange,
                      onApiKeyConfigUpdate: handleApiKeyConfigUpdate,
                      onOpenSourceConfigUpdate: handleOpenSourceConfigUpdate,
                    );
                  }
                  if (state is DeckGenerationLoadingState) {
                    return const SimpleLoadingWidget();
                  }
                  throw ArgumentError('Wrong state: $state');
                },
                listenWhen: (prevState, nextState) =>
                    nextState is ListenerState,
                listener: (BuildContext context, DeckGenerationState state) {
                  if (state is DeckGenerationUpdateSuccessState) {
                    snackBar(
                      context,
                      message: l10n.settingsDeckGenerationChangedMessage(
                        state.type.displayName(l10n),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  } else if (state is DeckGenerationApiKeyUpdatedState) {
                    snackBar(
                      context,
                      message: l10n.settingsAiValidatorApiKeySavedMessage(
                        state.type.displayName(l10n),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  } else if (state is DeckGenerationErrorState) {
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
