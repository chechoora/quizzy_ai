import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/config/app_config.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';
import 'package:poc_ai_quiz/l10n/localize.dart';
import 'package:poc_ai_quiz/util/alert_util.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/navigation.dart';
import 'package:poc_ai_quiz/view/auth/cubit/auth_cubit.dart';
import 'package:quizzy_design/quizzy_design.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthWidget extends HookWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(
      () => AuthCubit(
        authService: getIt<AuthService>(),
        inAppPurchaseService: getIt<InAppPurchaseService>(),
        logger: Logger.withTag('AuthCubit'),
      ),
    );

    useEffect(() => cubit.close, [cubit]);

    final l10n = localize(context);
    final appName = getIt<AppConfig>().appName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          bloc: cubit,
          buildWhen: (prev, next) => next is BuilderState,
          listenWhen: (prev, next) => next is ListenerState,
          listener: (context, state) {
            if (state is AuthErrorState) {
              snackBar(
                context,
                message:
                    state.error.isEmpty ? l10n.authErrorGeneric : state.error,
                isError: true,
              );
            } else if (state is AuthSignedInState) {
              context.pushReplacementNamed(HomeRoute().name);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        appName,
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          color: AppColors.grayscale600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.authSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.secondaryText.copyWith(
                          color: AppColors.grayscale500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton.primary(
                        text: l10n.authSignInWithGoogle,
                        leadingIcon: const Icon(Icons.login, size: 20),
                        onPressed: isLoading ? null : cubit.signInWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      if (Platform.isIOS)
                        AppButton.secondary(
                          text: l10n.authSignInWithApple,
                          leadingIcon: const Icon(Icons.apple, size: 22),
                          onPressed: isLoading ? null : cubit.signInWithApple,
                        ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(child: SimpleLoadingWidget()),
                    ),
                  ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 16,
                  child: _LegalLinksRow(
                    privacyPolicyUrl:
                        getIt<RemoteConfigService>().privacyPolicyUrl,
                    termsAndConditionsUrl:
                        getIt<RemoteConfigService>().termsAndConditionsUrl,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LegalLinksRow extends StatelessWidget {
  const _LegalLinksRow({
    required this.privacyPolicyUrl,
    required this.termsAndConditionsUrl,
  });

  final String privacyPolicyUrl;
  final String termsAndConditionsUrl;

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      snackBar(
        context,
        message: localize(context).authCouldNotOpenLinkError(url),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = localize(context);
    final linkStyle = AppTypography.smallText.copyWith(
      color: AppColors.primary500,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary500,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _launchUrl(context, privacyPolicyUrl),
          child: Text(l10n.authPrivacyPolicy, style: linkStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '•',
            style: AppTypography.smallText.copyWith(
              color: AppColors.grayscale500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _launchUrl(context, termsAndConditionsUrl),
          child: Text(l10n.authTermsAndConditions, style: linkStyle),
        ),
      ],
    );
  }
}
