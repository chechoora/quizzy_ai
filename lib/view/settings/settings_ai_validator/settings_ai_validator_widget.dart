import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/ext.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/answer_validator_dropdown.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/cubit/settings_cubit.dart';

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

    void handleApiKeyUpdate(AnswerValidatorType type, String? apiKey) {
      cubit.updateApiKey(type, apiKey);
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
            const SizedBox(
              height: 32,
            ),
            Text(
              l10n.settingsAiValidatorTitle,
              style: AppTypography.h2.copyWith(color: AppColors.grayscale600),
            ),
            Expanded(
              child: BlocConsumer<SettingsAIValidatorCubit, SettingsState>(
                bloc: cubit,
                buildWhen: (prevState, nextState) {
                  return nextState is BuilderState;
                },
                builder: (BuildContext context, state) {
                  if (state is SettingsDataState) {
                    return _ValidatorApiKeyContent(
                      selectedValidator: state.validatorType,
                      validators: state.validators,
                      onValidatorChanged: handleValidatorChange,
                      onApiKeyUpdate: handleApiKeyUpdate,
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
                        state.validatorType.toDisplayString(),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  } else if (state is SettingsApiKeyUpdatedState) {
                    snackBar(
                      context,
                      message: l10n.settingsAiValidatorApiKeySavedMessage(
                        state.validatorType.toDisplayString(),
                      ),
                      duration: const Duration(seconds: 2),
                    );
                  } else if (state is SettingsErrorState) {
                    snackBar(
                      context,
                      message: state.error,
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

class _ValidatorApiKeyContent extends HookWidget {
  const _ValidatorApiKeyContent({
    required this.selectedValidator,
    required this.validators,
    required this.onValidatorChanged,
    required this.onApiKeyUpdate,
    required this.onOpenSourceConfigUpdate,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final void Function(AnswerValidatorType?) onValidatorChanged;
  final void Function(AnswerValidatorType, String?) onApiKeyUpdate;
  final void Function(AnswerValidatorType, OpenSourceConfig?)
      onOpenSourceConfigUpdate;

  @override
  Widget build(BuildContext context) {
    final selectedValidatorItem = validators.firstWhere(
      (v) => v.type == selectedValidator,
      orElse: () => validators.first,
    );

    final validatorConfig = selectedValidatorItem.validatorConfig;
    final l10n = localize(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text(
          l10n.settingsAiValidatorLabel,
          style: AppTypography.h4.copyWith(color: AppColors.grayscale600),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.settingsAiValidatorSubtitle,
          style: AppTypography.secondaryText.copyWith(
            color: AppColors.grayscale500,
          ),
        ),
        const SizedBox(height: 24),
        AnswerValidatorDropdown(
          selectedValidator: selectedValidator,
          validators: validators,
          onValidatorChanged: onValidatorChanged,
        ),
        const SizedBox(height: 24),
        switch (validatorConfig) {
          ApiKeyConfig() => _ApiKeyTextField(
              initialApiKey: validatorConfig.apiKey,
              selectedValidator: selectedValidator,
              onApiKeyUpdate: onApiKeyUpdate,
            ),
          OpenSourceConfig() => _OpenSourceModelConfigField(
              initialConfig:
                  selectedValidatorItem.validatorConfig as OpenSourceConfig?,
              selectedValidator: selectedValidator,
              onConfigUpdate: onOpenSourceConfigUpdate,
            ),
          PurchaseConfig() => const SizedBox.shrink(),
          null => const SizedBox.shrink(),
        },
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grayscaleWhite,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsAiValidatorOptionsTitle,
                style: AppTypography.h4.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
              const SizedBox(height: 8),
              if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                Text(
                  l10n.settingsAiValidatorOnDeviceDescription,
                  style: AppTypography.secondaryText.copyWith(
                    color: AppColors.grayscale500,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                l10n.settingsAiValidatorClaudeDescription,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsAiValidatorOpenAIDescription,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsAiValidatorGeminiDescription,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsAiValidatorMlDescription,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsAiValidatorOllamaDescription,
                style: AppTypography.secondaryText.copyWith(
                  color: AppColors.grayscale500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApiKeyTextField extends HookWidget {
  const _ApiKeyTextField({
    required this.initialApiKey,
    required this.selectedValidator,
    required this.onApiKeyUpdate,
  });

  final String? initialApiKey;
  final AnswerValidatorType selectedValidator;
  final void Function(AnswerValidatorType, String?) onApiKeyUpdate;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialApiKey ?? '');

    useEffect(() {
      controller.text = initialApiKey ?? '';
      return null;
    }, [selectedValidator, initialApiKey]);

    final l10n = localize(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAiValidatorApiKeyTitle,
            style: AppTypography.h4.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grayscale300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grayscale300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary500),
              ),
              labelText: l10n.settingsAiValidatorApiKeyLabel(
                selectedValidator.toDisplayString(),
              ),
              labelStyle: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale500,
              ),
              hintText: l10n.settingsAiValidatorApiKeyHint,
              hintStyle: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale400,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.save, color: AppColors.primary500),
                onPressed: () {
                  final apiKey = controller.text.trim().isEmpty
                      ? null
                      : controller.text.trim();
                  onApiKeyUpdate(selectedValidator, apiKey);
                },
                tooltip: l10n.settingsAiValidatorApiKeySaveTooltip,
              ),
            ),
            style: AppTypography.mainText.copyWith(
              color: AppColors.grayscale600,
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class _OpenSourceModelConfigField extends HookWidget {
  const _OpenSourceModelConfigField({
    required this.initialConfig,
    required this.selectedValidator,
    required this.onConfigUpdate,
  });

  final OpenSourceConfig? initialConfig;
  final AnswerValidatorType selectedValidator;
  final void Function(AnswerValidatorType, OpenSourceConfig?) onConfigUpdate;

  @override
  Widget build(BuildContext context) {
    final urlController =
        useTextEditingController(text: initialConfig?.url ?? '');
    final modelController =
        useTextEditingController(text: initialConfig?.model ?? '');

    useEffect(() {
      urlController.text = initialConfig?.url ?? '';
      modelController.text = initialConfig?.model ?? '';
      return null;
    }, [selectedValidator, initialConfig]);

    final l10n = localize(context);
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grayscale300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grayscale300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary500),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grayscaleWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAiValidatorApiConfigTitle,
            style: AppTypography.h4.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: urlController,
            decoration: inputDecoration.copyWith(
              labelText: l10n.settingsAiValidatorServerUrlLabel,
              labelStyle: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale500,
              ),
              hintText: l10n.settingsAiValidatorServerUrlHint,
              hintStyle: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale400,
              ),
            ),
            style: AppTypography.mainText.copyWith(
              color: AppColors.grayscale600,
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: modelController,
            decoration: inputDecoration.copyWith(
              labelText: l10n.settingsAiValidatorModelNameLabel,
              labelStyle: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale500,
              ),
              hintText: l10n.settingsAiValidatorModelNameHint,
              hintStyle: AppTypography.secondaryText.copyWith(
                color: AppColors.grayscale400,
              ),
            ),
            style: AppTypography.mainText.copyWith(
              color: AppColors.grayscale600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final url = urlController.text.trim();
                final model = modelController.text.trim();
                if (url.isEmpty && model.isEmpty) {
                  onConfigUpdate(selectedValidator, null);
                } else if (url.isEmpty || model.isEmpty) {
                  snackBar(context,
                      message: l10n.settingsAiValidatorFillBothFieldsError);
                } else {
                  onConfigUpdate(
                    selectedValidator,
                    OpenSourceConfig(url: url, model: model),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.grayscaleWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                l10n.settingsAiValidatorSaveConfigButton,
                style: AppTypography.buttonMain.copyWith(
                  color: AppColors.grayscaleWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
