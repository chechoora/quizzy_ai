import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
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
              onChanged: handleValidatorChange,
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
          } else if (state is SettingsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update settings'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.selectedValidator,
    required this.validators,
    required this.onChanged,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final void Function(AnswerValidatorType?) onChanged;

  @override
  Widget build(BuildContext context) {
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
            onChanged: onChanged,
          ),
        ),
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
                    '• Gemini AI: Uses Google Gemini AI for intelligent answer validation',
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• On-Device AI: Uses local AI processing for privacy and offline use',
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Text Similarity: Uses text similarity algorithms for basic matching',
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
