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
import 'package:poc_ai_quiz/util/simple_loading_widget.dart';
import 'package:poc_ai_quiz/view/settings/cubit/settings_cubit.dart';

class SettingsWidget extends HookWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => SettingsCubit(
        settingsService: getIt<SettingsService>(),
        validatorsManager: getIt<ValidatorsManager>(),
        userRepository: getIt<UserRepository>(),
        userSettingsRepository:  getIt<UserSettingsRepository>(),
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
        title: const Text('Settings'),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        bloc: cubit,
        buildWhen: (prevState, nextState) {
          return nextState is BuilderState;
        },
        builder: (BuildContext context, state) {
          if (state is SettingsDataState) {
            return _SettingsContent(
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

class _SettingsContent extends HookWidget {
  const _SettingsContent({
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
    // Create controllers for each API key field
    final controllers = useMemoized(() {
      final Map<AnswerValidatorType, TextEditingController> map = {};
      for (var validator in validators) {
        if (validator.type != AnswerValidatorType.onDeviceAI) {
          map[validator.type] = TextEditingController(text: validator.apiKey ?? '');
        }
      }
      return map;
    });

    // Update controllers when validators change
    useEffect(() {
      for (var validator in validators) {
        if (validator.type != AnswerValidatorType.onDeviceAI) {
          final controller = controllers[validator.type];
          if (controller != null && controller.text != (validator.apiKey ?? '')) {
            controller.text = validator.apiKey ?? '';
          }
        }
      }
      return null;
    }, [validators]);

    // Dispose controllers
    useEffect(() {
      return () {
        for (var controller in controllers.values) {
          controller.dispose();
        }
      };
    }, []);

    return ListView(
      children: [
        const ListTile(
          title: Text('Answer Validator'),
          subtitle: Text('Choose how quiz answers are validated'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButtonFormField<AnswerValidatorType>(
            value: selectedValidator,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Validator Type',
            ),
            items: validators.map((validatorItem) {
              return DropdownMenuItem(
                value: validatorItem.type,
                enabled: validatorItem.isEnabled,
                child: Row(
                  children: [
                    Text(
                      validatorItem.type.toDisplayString(),
                      style: TextStyle(
                        color: validatorItem.isEnabled
                            ? null
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                    if (!validatorItem.isEnabled) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: Theme.of(context).disabledColor,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: onValidatorChanged,
          ),
        ),
        const SizedBox(height: 24),
        // API Keys Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'API Keys',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...validators
            .where((v) => v.type != AnswerValidatorType.onDeviceAI)
            .map((validator) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: controllers[validator.type],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '${validator.type.toDisplayString()} API Key',
                      hintText: 'Enter your API key',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          final controller = controllers[validator.type];
                          if (controller != null) {
                            final apiKey = controller.text.trim().isEmpty
                                ? null
                                : controller.text.trim();
                            onApiKeyUpdate(validator.type, apiKey);
                          }
                        },
                        tooltip: 'Save API Key',
                      ),
                    ),
                    obscureText: true,
                    onSubmitted: (value) {
                      final apiKey = value.trim().isEmpty ? null : value.trim();
                      onApiKeyUpdate(validator.type, apiKey);
                    },
                  ),
                )),
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
                    '• Gemini AI: Requires a Google Gemini API key. Uses Google AI for intelligent answer validation.',
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
                    '• On-Device AI: No API key required. Uses local AI processing for privacy and offline use.',
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
