import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              localize(context).settingsTitle,
              style: AppTypography.h2.copyWith(color: AppColors.grayscale600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SettingsTile(
                    icon: Icons.smart_toy,
                    title: localize(context).settingsAiValidatorTitle,
                    subtitle: localize(context).settingsAiValidatorSubtitleTile,
                    onTap: () =>
                        context.pushNamed(SettingsAIValidatorRoute().name),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.import_export,
                    title: localize(context).settingsImportExportTitle,
                    subtitle: localize(context).settingsImportExportSubtitle,
                    onTap: () =>
                        context.pushNamed(SettingsImportExportRoute().name),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.shopping_bag,
                    title: localize(context).inAppFeaturesTitle,
                    subtitle: localize(context).settingsInAppFeaturesSubtitle,
                    onTap: () =>
                        context.pushNamed(SettingsInAppFeaturesRoute().name),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayscaleWhite,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary500, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.grayscale600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.secondaryText.copyWith(
                      color: AppColors.grayscale500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.grayscale400,
            ),
          ],
        ),
      ),
    );
  }
}
