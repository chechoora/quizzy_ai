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
import 'package:poc_ai_quiz/util/view/answer_validator_dropdown.dart';
import 'package:poc_ai_quiz/util/view/simple_loading_widget.dart';
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
      appBar: AppBar(
        title: Text(l10n.settingsAiValidatorTitle),
      ),
      body: BlocConsumer<SettingsAIValidatorCubit, SettingsState>(
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.settingsAiValidatorChangedMessage(
                    state.validatorType.toDisplayString(),
                  ),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is SettingsApiKeyUpdatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.settingsAiValidatorApiKeySavedMessage(
                    state.validatorType.toDisplayString(),
                  ),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is SettingsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
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

    final validatorCategory = selectedValidator.category;
    final validatorConfig = selectedValidatorItem.validatorConfig;
    final l10n = localize(context);
    return ListView(
      children: [
        ListTile(
          title: Text(l10n.settingsAiValidatorLabel),
          subtitle: Text(l10n.settingsAiValidatorSubtitle),
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsAiValidatorOptionsTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                    Text(l10n.settingsAiValidatorOnDeviceDescription),
                    const SizedBox(height: 4),
                  ],
                  Text(l10n.settingsAiValidatorClaudeDescription),
                  const SizedBox(height: 4),
                  Text(l10n.settingsAiValidatorOpenAIDescription),
                  const SizedBox(height: 4),
                  Text(l10n.settingsAiValidatorGeminiDescription),
                  const SizedBox(height: 4),
                  Text(l10n.settingsAiValidatorMlDescription),
                  const SizedBox(height: 4),
                  Text(l10n.settingsAiValidatorOllamaDescription),
                ],
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.settingsAiValidatorApiKeyTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.settingsAiValidatorApiKeyLabel(
                selectedValidator.toDisplayString(),
              ),
              hintText: l10n.settingsAiValidatorApiKeyHint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  final apiKey = controller.text.trim().isEmpty
                      ? null
                      : controller.text.trim();
                  onApiKeyUpdate(selectedValidator, apiKey);
                },
                tooltip: l10n.settingsAiValidatorApiKeySaveTooltip,
              ),
            ),
            obscureText: true,
          ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.settingsAiValidatorApiConfigTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: urlController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.settingsAiValidatorServerUrlLabel,
              hintText: l10n.settingsAiValidatorServerUrlHint,
            ),
            keyboardType: TextInputType.url,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: modelController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.settingsAiValidatorModelNameLabel,
              hintText: l10n.settingsAiValidatorModelNameHint,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FilledButton.icon(
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
            icon: const Icon(Icons.save),
            label: Text(l10n.settingsAiValidatorSaveConfigButton),
          ),
        ),
      ],
    );
  }
}
