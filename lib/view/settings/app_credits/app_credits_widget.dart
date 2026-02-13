import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/theme/app_colors.dart';
import 'package:poc_ai_quiz/util/theme/app_typography.dart';
import 'package:poc_ai_quiz/view/widgets/app_simple_header.dart';
import 'package:url_launcher/url_launcher.dart';

class AppCreditsWidget extends StatelessWidget {
  const AppCreditsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            AppSimpleHeader(
              title: l10n.settingsAppCreditsTitle,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CreditTile(
                    role: l10n.appCreditsRoleFlutterDeveloper,
                    name: 'Kyrylo Kharchenko',
                    url: 'https://github.com/chechoora',
                    icon: Icons.code,
                  ),
                  const SizedBox(height: 12),
                  _CreditTile(
                    role: l10n.appCreditsRoleBackendDeveloper,
                    name: 'Volodymyr Soloviov',
                    url: 'https://github.com/vartaller',
                    icon: Icons.dns,
                  ),
                  const SizedBox(height: 12),
                  _CreditTile(
                    role: l10n.appCreditsRoleDesigner,
                    name: 'Alina Fedorenko',
                    url: 'https://www.linkedin.com/in/a-fedorenko/',
                    icon: Icons.palette,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Text(
              l10n.appCreditsFromUkraine,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({
    required this.role,
    required this.name,
    required this.url,
    required this.icon,
  });

  final String role;
  final String name;
  final String url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
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
                    name,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.grayscale600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: AppTypography.secondaryText.copyWith(
                      color: AppColors.grayscale500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: AppColors.grayscale400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
