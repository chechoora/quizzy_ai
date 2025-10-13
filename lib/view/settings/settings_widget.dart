import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SettingsWidget extends HookWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = useMemoized(() => Logger.withTag('SettingsWidget'));
    final settingsService = useMemoized(() => getIt.get<SettingsService>());
    final selectedValidator = useState<AnswerValidatorType?>(null);
    final isLoading = useState(true);

    useEffect(() {
      Future<void> loadSettings() async {
        try {
          final validatorType = await settingsService.getCurrentValidatorType();
          selectedValidator.value = validatorType;
          isLoading.value = false;
        } catch (e, stackTrace) {
          logger.e('Failed to load settings', ex: e, stacktrace: stackTrace);
          isLoading.value = false;
        }
      }

      loadSettings();
      return null;
    }, []);

    Future<void> updateValidator(AnswerValidatorType? newValidator) async {
      if (newValidator == null || newValidator == selectedValidator.value) return;

      try {
        await settingsService.updateValidatorType(newValidator);
        selectedValidator.value = newValidator;
        logger.i('Updated validator to: ${newValidator.toDisplayString()}');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Answer validator changed to ${newValidator.toDisplayString()}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e, stackTrace) {
        logger.e('Failed to update validator', ex: e, stacktrace: stackTrace);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update settings'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const ListTile(
                  title: Text('Answer Validator'),
                  subtitle: Text('Choose how quiz answers are validated'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<AnswerValidatorType>(
                    value: selectedValidator.value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Validator Type',
                    ),
                    items: AnswerValidatorType.values.map((validator) {
                      return DropdownMenuItem(
                        value: validator,
                        child: Text(validator.toDisplayString()),
                      );
                    }).toList(),
                    onChanged: updateValidator,
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
            ),
    );
  }
}
