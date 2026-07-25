import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/view/auth/cubit/auth_cubit.dart';

class MockAuthService extends Mock implements AuthService {}

class MockInAppPurchaseService extends Mock implements InAppPurchaseService {}

class MockSettingsService extends Mock implements SettingsService {}

class FakeLogger extends Mock implements Logger {}

void main() {
  late MockAuthService authService;
  late MockInAppPurchaseService inAppPurchaseService;
  late MockSettingsService settingsService;

  AuthCubit buildCubit({required bool isSubscriptionOnly}) => AuthCubit(
        authService: authService,
        inAppPurchaseService: inAppPurchaseService,
        settingsService: settingsService,
        isSubscriptionOnly: isSubscriptionOnly,
        logger: FakeLogger(),
      );

  setUpAll(() {
    registerFallbackValue(AnswerValidatorType.ml);
  });

  setUp(() {
    authService = MockAuthService();
    inAppPurchaseService = MockInAppPurchaseService();
    settingsService = MockSettingsService();
    when(() => inAppPurchaseService.logInUser(any()))
        .thenAnswer((_) async {});
    when(() => settingsService.updateValidatorType(any()))
        .thenAnswer((_) async {});
    when(() => settingsService.updateDeckGenerationAiType(any()))
        .thenAnswer((_) async {});
  });

  const user = AuthUser(uid: 'uid-1', email: 'a@b.com');

  group('sign-in flow', () {
    late AuthCubit cubit;

    setUp(() => cubit = buildCubit(isSubscriptionOnly: false));
    tearDown(() => cubit.close());

    test('signInWithGoogle emits loading -> signedIn -> idle on success',
        () async {
      when(() => authService.signInWithGoogle())
          .thenAnswer((_) async => user);

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoadingState>(),
          isA<AuthSignedInState>(),
          isA<AuthIdleState>(),
        ]),
      );

      await cubit.signInWithGoogle();
      await states;
      verify(() => authService.signInWithGoogle()).called(1);
    });

    test('signInWithApple emits loading -> error -> idle on failure',
        () async {
      when(() => authService.signInWithApple())
          .thenThrow(const AuthException('boom'));

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoadingState>(),
          isA<AuthErrorState>().having((s) => s.error, 'error', 'boom'),
          isA<AuthIdleState>(),
        ]),
      );

      await cubit.signInWithApple();
      await states;
    });

    test('cancellation emits loading -> idle without an error state',
        () async {
      when(() => authService.signInWithGoogle())
          .thenThrow(const AuthCancelledException());

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoadingState>(),
          isA<AuthIdleState>(),
        ]),
      );

      await cubit.signInWithGoogle();
      await states;
    });
  });

  group('quizzyAI entitlement on login (isSubscriptionOnly)', () {
    late AuthCubit cubit;

    setUp(() {
      cubit = buildCubit(isSubscriptionOnly: true);
      when(() => authService.signInWithGoogle()).thenAnswer((_) async => user);
    });
    tearDown(() => cubit.close());

    test('sets Quizzy AI as default validator when already subscribed',
        () async {
      when(() => inAppPurchaseService
              .isFeaturePurchased(InAppPurchaseFeature.quizzyAi))
          .thenAnswer((_) async => true);

      await cubit.signInWithGoogle();

      verify(() => settingsService
          .updateValidatorType(AnswerValidatorType.quizzyAI)).called(1);
      verify(() => settingsService
          .updateDeckGenerationAiType(AnswerValidatorType.quizzyAI)).called(1);
    });

    test('leaves validator untouched when not subscribed', () async {
      when(() => inAppPurchaseService
              .isFeaturePurchased(InAppPurchaseFeature.quizzyAi))
          .thenAnswer((_) async => false);

      await cubit.signInWithGoogle();

      verifyNever(() => settingsService.updateValidatorType(any()));
      verifyNever(() => settingsService.updateDeckGenerationAiType(any()));
    });
  });
}
