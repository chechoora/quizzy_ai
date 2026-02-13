import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                    icon: SvgPicture.asset(
                      'assets/icons/stars.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary500,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: localize(context).settingsAiValidatorTitle,
                    subtitle: localize(context).settingsAiValidatorSubtitleTile,
                    onTap: () =>
                        context.pushNamed(SettingsAIValidatorRoute().name),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: SvgPicture.asset(
                      'assets/icons/import_export.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary500,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: localize(context).settingsImportExportTitle,
                    subtitle: localize(context).settingsImportExportSubtitle,
                    onTap: () =>
                        context.pushNamed(SettingsImportExportRoute().name),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: SvgPicture.asset(
                      'assets/icons/crown.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary500,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: localize(context).inAppFeaturesTitle,
                    subtitle: localize(context).settingsInAppFeaturesSubtitle,
                    onTap: () =>
                        context.pushNamed(SettingsInAppFeaturesRoute().name),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: const Icon(
                      Icons.people,
                      color: AppColors.primary500,
                      size: 24,
                    ),
                    title: localize(context).settingsAppCreditsTitle,
                    subtitle: localize(context).settingsAppCreditsSubtitle,
                    onTap: () =>
                        context.pushNamed(AppCreditsRoute().name),
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

  final Widget icon;
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
            icon,
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
