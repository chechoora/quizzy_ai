import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/view/settings/cubit/settings_menu_cubit.dart';
import 'package:quizzy_design/quizzy_design.dart';

class SettingsWidget extends HookWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => SettingsMenuCubit(
        appConfig: getIt<AppConfig>(),
        authService: getIt<AuthService>(),
        logger: Logger.withTag('SettingsMenuCubit'),
      ),
    );
    useEffect(() => cubit.close, [cubit]);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SettingsMenuCubit, SettingsMenuState>(
          bloc: cubit,
          buildWhen: (prev, next) => next is BuilderState,
          listenWhen: (prev, next) => next is ListenerState,
          listener: (context, state) {
            if (state is SettingsMenuErrorState) {
              snackBar(context, message: state.error, isError: true);
            }
          },
          builder: (context, state) {
            if (state is SettingsMenuLoadingState) {
              return const Center(child: SimpleLoadingWidget());
            }
            if (state is SettingsMenuIdleState) {
              return _SettingsMenu(state: state, cubit: cubit);
            }
            throw ArgumentError('Wrong state: $state');
          },
        ),
      ),
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({required this.state, required this.cubit});

  final SettingsMenuIdleState state;
  final SettingsMenuCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    return Column(
      children: [
        const SizedBox(height: 32),
        Text(
          l10n.settingsTitle,
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
                title: l10n.settingsAiValidatorTitle,
                subtitle: l10n.settingsAiValidatorSubtitleTile,
                onTap: () => context.pushNamed(SettingsAIValidatorRoute().name),
              ),
              const SizedBox(height: 12),
              if (state.enableByok) ...[
                _SettingsTile(
                  icon: SvgPicture.asset(
                    'assets/icons/deck_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary500,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: l10n.settingsDeckGenerationTitle,
                  subtitle: l10n.settingsDeckGenerationSubtitleTile,
                  onTap: () =>
                      context.pushNamed(SettingsDeckGenerationRoute().name),
                ),
                const SizedBox(height: 12),
              ],
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
                title: l10n.settingsImportExportTitle,
                subtitle: l10n.settingsImportExportSubtitle,
                onTap: () => context.pushNamed(SettingsImportExportRoute().name),
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
                title: l10n.inAppFeaturesTitle,
                subtitle: l10n.settingsInAppFeaturesSubtitle,
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
                title: l10n.settingsAppCreditsTitle,
                subtitle: l10n.settingsAppCreditsSubtitle,
                onTap: () => context.pushNamed(AppCreditsRoute().name),
              ),
              if (state.requireAuth) ...[
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                  title: l10n.settingsSignOutTitle,
                  subtitle: l10n.settingsSignOutSubtitle,
                  onTap: () => _confirmSignOut(context),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppColors.error500,
                    size: 24,
                  ),
                  title: l10n.settingsDeleteAccountTitle,
                  subtitle: l10n.settingsDeleteAccountSubtitle,
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = localize(context);
    final confirmed = await alert(
      context,
      title: Text(
        l10n.settingsSignOutTitle,
        style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
      ),
      content: Text(
        l10n.settingsSignOutConfirm,
        style: AppTypography.secondaryText.copyWith(
          color: AppColors.grayscale500,
        ),
      ),
      primary: AppDialogButton.destructive(
        text: l10n.settingsSignOutTitle,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed == true) {
      cubit.signOut();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = localize(context);
    final confirmed = await alert(
      context,
      title: Text(
        l10n.settingsDeleteAccountTitle,
        style: AppTypography.h3.copyWith(color: AppColors.grayscale600),
      ),
      content: Text(
        l10n.settingsDeleteAccountConfirm,
        style: AppTypography.secondaryText.copyWith(
          color: AppColors.grayscale500,
        ),
      ),
      primary: AppDialogButton.destructive(
        text: l10n.settingsDeleteAccountTitle,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed == true) {
      cubit.deleteAccount();
    }
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