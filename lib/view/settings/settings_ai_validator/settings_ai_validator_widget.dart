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

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Validator'),
      ),
      body: BlocConsumer<SettingsAIValidatorCubit, SettingsState>(
        bloc: cubit,
        buildWhen: (prevState, nextState) {
          return nextState is BuilderState;
        },
        builder: (BuildContext context, state) {
          if (state is SettingsDataState) {
            return _ValidatorContent(
              selectedValidator: state.validatorType,
              validators: state.validators,
              onValidatorChanged: handleValidatorChange,
              onApiKeyUpdate: handleApiKeyUpdate,
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
                  'Answer validator changed to ${state.validatorType.toDisplayString()}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is SettingsApiKeyUpdatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'API key saved for ${state.validatorType.toDisplayString()}',
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

class _ValidatorContent extends HookWidget {
  const _ValidatorContent({
    required this.selectedValidator,
    required this.validators,
    required this.onValidatorChanged,
    required this.onApiKeyUpdate,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final void Function(AnswerValidatorType?) onValidatorChanged;
  final void Function(AnswerValidatorType, String?) onApiKeyUpdate;

  @override
  Widget build(BuildContext context) {
    final selectedValidatorItem = validators.firstWhere(
      (v) => v.type == selectedValidator,
      orElse: () => validators.first,
    );

    final apiKeyController = useTextEditingController(
      text: selectedValidatorItem.apiKey ?? '',
    );

    useEffect(() {
      apiKeyController.text = selectedValidatorItem.apiKey ?? '';
      return null;
    }, [selectedValidator, selectedValidatorItem.apiKey]);

    return ListView(
      children: [
        const ListTile(
          title: Text('Answer Validator'),
          subtitle: Text('Choose how quiz answers are validated'),
        ),
        AnswerValidatorDropdown(
          selectedValidator: selectedValidator,
          validators: validators,
          onValidatorChanged: onValidatorChanged,
        ),
        const SizedBox(height: 24),
        if (selectedValidator != AnswerValidatorType.onDeviceAI) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'API Key',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '${selectedValidator.toDisplayString()} API Key',
                hintText: 'Enter your API key',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    final apiKey = apiKeyController.text.trim().isEmpty
                        ? null
                        : apiKeyController.text.trim();
                    onApiKeyUpdate(selectedValidator, apiKey);
                  },
                  tooltip: 'Save API Key',
                ),
              ),
              obscureText: true,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validator Options:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• On-Device AI: No API key required. Uses local AI processing for privacy and offline use.',
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Claude AI: Requires an Anthropic API key. Uses Claude models for answer evaluation.',
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• OpenAI: Requires an OpenAI API key. Uses GPT models for answer validation.',
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Gemini AI: Requires a Google Gemini API key. Uses Google AI for intelligent answer validation.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}