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
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_button.dart';
import 'package:poc_ai_quiz/view/widgets/app_simple_header.dart';
import 'package:poc_ai_quiz/view/widgets/app_text_field.dart';
import 'package:poc_ai_quiz/view/widgets/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/cubit/settings_cubit.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/quota/quota_display_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_type_bottom_sheet.dart';

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
          style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsAiValidatorSubtitle,
          style: AppTypography.mainText.copyWith(
            color: AppColors.grayscale500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.answerValidatorDropdownLabel,
          style: AppTypography.h4.copyWith(color: AppColors.grayscale600),
        ),
        const SizedBox(height: 12),
        _ValidatorDropdownTrigger(
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
          PurchaseConfig() => const QuotaDisplayWidget(),
          null => const SizedBox.shrink(),
        },
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
    final isEmpty = useState(controller.text.trim().isEmpty);
    final isUnchanged = useState(controller.text.trim() == (initialApiKey ?? ''));

    useEffect(() {
      controller.text = initialApiKey ?? '';
      isEmpty.value = controller.text.trim().isEmpty;
      isUnchanged.value = controller.text.trim() == (initialApiKey ?? '');
      return null;
    }, [selectedValidator, initialApiKey]);

    useEffect(() {
      void listener() {
        isEmpty.value = controller.text.trim().isEmpty;
        isUnchanged.value = controller.text.trim() == (initialApiKey ?? '');
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    final l10n = localize(context);
    final hasInitialKey = initialApiKey != null && initialApiKey!.isNotEmpty;
    final showDeleteButton = hasInitialKey && isUnchanged.value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
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
              AppTextField(
                controller: controller,
                hint: l10n.settingsAiValidatorApiKeyHint,
                obscureText: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        showDeleteButton
            ? AppButton.destructive(
                text: 'Delete',
                onPressed: () {
                  onApiKeyUpdate(selectedValidator, null);
                },
              )
            : AppButton.primary(
                text: 'Apply',
                onPressed: isEmpty.value
                    ? null
                    : () {
                        final apiKey = controller.text.trim();
                        onApiKeyUpdate(selectedValidator, apiKey);
                      },
              ),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsAiValidatorApiConfigTitle,
          style: AppTypography.h4.copyWith(
            color: AppColors.grayscale600,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: urlController,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: modelController,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            text: l10n.settingsAiValidatorSaveConfigButton,
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
          ),
        ),
      ],
    );
  }
}

class _ValidatorDropdownTrigger extends StatelessWidget {
  const _ValidatorDropdownTrigger({
    required this.selectedValidator,
    required this.validators,
    required this.onValidatorChanged,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final void Function(AnswerValidatorType?) onValidatorChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showValidatorTypeBottomSheet(
          context,
          selectedValidator: selectedValidator,
          validators: validators,
        );
        if (result != null) {
          onValidatorChanged(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValidator.toDisplayString(),
                style: AppTypography.mainText.copyWith(
                  color: AppColors.grayscale600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: AppColors.grayscale600,
            ),
          ],
        ),
      ),
    );
  }
}
