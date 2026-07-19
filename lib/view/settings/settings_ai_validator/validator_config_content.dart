import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/quota/quota_display_widget.dart';
import 'package:poc_ai_quiz/view/settings/settings_ai_validator/validator_type_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared provider-selection + per-provider config UI, used by both the AI
/// Validator screen and the Deck Generation screen. The section header strings
/// and the picker title are supplied by the host screen; everything else
/// (API-key/model fields, Ollama config, Quizzy quota) is identical because the
/// per-provider config storage is shared.
class ValidatorConfigContent extends HookWidget {
  const ValidatorConfigContent({
    super.key,
    required this.selectedValidator,
    required this.validators,
    required this.sectionLabel,
    required this.sectionSubtitle,
    required this.dropdownLabel,
    required this.onValidatorChanged,
    required this.onApiKeyConfigUpdate,
    required this.onOpenSourceConfigUpdate,
    this.bottomSheetTitle,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final String sectionLabel;
  final String sectionSubtitle;
  final String dropdownLabel;
  final String? bottomSheetTitle;
  final void Function(AnswerValidatorType?) onValidatorChanged;
  final void Function(AnswerValidatorType, ApiKeyConfig?) onApiKeyConfigUpdate;
  final void Function(AnswerValidatorType, OpenSourceConfig?)
      onOpenSourceConfigUpdate;

  @override
  Widget build(BuildContext context) {
    final selectedValidatorItem = validators.firstWhere(
      (v) => v.type == selectedValidator,
      orElse: () => validators.first,
    );

    final validatorConfig = selectedValidatorItem.validatorConfig;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text(
          sectionLabel,
          style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          sectionSubtitle,
          style: AppTypography.mainText.copyWith(
            color: AppColors.grayscale500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          dropdownLabel,
          style: AppTypography.h4.copyWith(color: AppColors.grayscale600),
        ),
        const SizedBox(height: 12),
        ValidatorDropdownTrigger(
          selectedValidator: selectedValidator,
          validators: validators,
          bottomSheetTitle: bottomSheetTitle,
          onValidatorChanged: onValidatorChanged,
        ),
        const SizedBox(height: 24),
        switch (validatorConfig) {
          ApiKeyConfig() => ApiKeyWithModelField(
              initialConfig: validatorConfig,
              selectedValidator: selectedValidator,
              onConfigUpdate: onApiKeyConfigUpdate,
            ),
          OpenSourceConfig() => OpenSourceModelConfigField(
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

class ApiKeyWithModelField extends HookWidget {
  const ApiKeyWithModelField({
    super.key,
    required this.initialConfig,
    required this.selectedValidator,
    required this.onConfigUpdate,
  });

  final ApiKeyConfig? initialConfig;
  final AnswerValidatorType selectedValidator;
  final void Function(AnswerValidatorType, ApiKeyConfig?) onConfigUpdate;

  String? _getApiKeyUrl(BuildContext context) {
    final l10n = localize(context);
    return switch (selectedValidator) {
      AnswerValidatorType.claude => l10n.settingsAiValidatorClaudeLink,
      AnswerValidatorType.openAI => l10n.settingsAiValidatorOpenAILink,
      AnswerValidatorType.gemini => l10n.settingsAiValidatorGeminiLink,
      _ => null,
    };
  }

  Future<void> _launchApiKeyUrl(BuildContext context) async {
    final url = _getApiKeyUrl(context);
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          final l10n = localize(context);
          snackBar(
            context,
            message: l10n.settingsAiValidatorCouldNotOpenUrlError(url),
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyController =
        useTextEditingController(text: initialConfig?.apiKey ?? '');
    final modelController =
        useTextEditingController(text: initialConfig?.model ?? '');

    useEffect(() {
      apiKeyController.text = initialConfig?.apiKey ?? '';
      modelController.text = initialConfig?.model ?? '';
      return null;
    }, [selectedValidator, initialConfig]);

    final l10n = localize(context);

    return Column(
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
          controller: apiKeyController,
          hint: l10n.settingsAiValidatorApiKeyHint,
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.settingsAiValidatorModelNameLabel,
          style: AppTypography.h4.copyWith(
            color: AppColors.grayscale600,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: modelController,
          hint: l10n.settingsAiValidatorModelNameHint,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            text: l10n.settingsAiValidatorSaveConfigButton,
            onPressed: () {
              final apiKey = apiKeyController.text.trim();
              final model = modelController.text.trim();
              if (apiKey.isEmpty && model.isEmpty) {
                onConfigUpdate(selectedValidator, null);
              } else if (apiKey.isEmpty || model.isEmpty) {
                snackBar(context,
                    message: l10n.settingsAiValidatorFillBothFieldsError);
              } else {
                onConfigUpdate(
                  selectedValidator,
                  ApiKeyConfig(apiKey: apiKey, model: model),
                );
              }
            },
          ),
        ),
        if (_getApiKeyUrl(context) != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _launchApiKeyUrl(context),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  l10n.settingsAiValidatorGetApiKeyLink,
                  style: AppTypography.smallText.copyWith(
                    color: AppColors.primary500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: AppColors.primary500,
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

class OpenSourceModelConfigField extends HookWidget {
  const OpenSourceModelConfigField({
    super.key,
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
          hint: l10n.settingsAiValidatorServerUrlHint,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: modelController,
          hint: l10n.settingsAiValidatorModelNameHint,
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

class ValidatorDropdownTrigger extends StatelessWidget {
  const ValidatorDropdownTrigger({
    super.key,
    required this.selectedValidator,
    required this.validators,
    required this.onValidatorChanged,
    this.bottomSheetTitle,
  });

  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> validators;
  final String? bottomSheetTitle;
  final void Function(AnswerValidatorType?) onValidatorChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showValidatorTypeBottomSheet(
          context,
          selectedValidator: selectedValidator,
          validators: validators,
          title: bottomSheetTitle,
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
