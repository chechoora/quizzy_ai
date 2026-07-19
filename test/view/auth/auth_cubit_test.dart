import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/auth/auth_service.dart';
import 'package:poc_ai_quiz/domain/auth/model/auth_user.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/view/auth/cubit/auth_cubit.dart';

class MockAuthService extends Mock implements AuthService {}

class FakeLogger extends Mock implements Logger {}

void main() {
  late MockAuthService authService;
  late AuthCubit cubit;

  setUp(() {
    authService = MockAuthService();
    cubit = AuthCubit(authService: authService, logger: FakeLogger());
  });

  tearDown(() => cubit.close());

  const user = AuthUser(uid: 'uid-1', email: 'a@b.com');

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

  test('signInWithApple emits loading -> error -> idle on failure', () async {
    when(() => authService.signInWithApple())
        .thenThrow(const AuthException('boom'));

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<AuthLoadingState>(),
        isA<AuthErrorState>()
            .having((s) => s.error, 'error', 'boom'),
        isA<AuthIdleState>(),
      ]),
    );

    await cubit.signInWithApple();
    await states;
  });

  test('cancellation emits loading -> idle without an error state', () async {
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
}