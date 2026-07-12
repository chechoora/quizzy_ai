import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/ai_gen/mock_ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/view/ai_generate/cubit/ai_generate_cubit.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockDeckPremiumManager extends Mock implements DeckPremiumManager {}

void main() {
  late MockDeckRepository deckRepository;
  late MockQuizCardRepository quizCardRepository;
  late MockDeckPremiumManager deckPremiumManager;

  setUpAll(() {
    registerFallbackValue(<PlainCardModel>[]);
  });

  AiGenerateCubit buildCubit() => AiGenerateCubit(
        aiGenService: MockAiGenService(),
        deckRepository: deckRepository,
        quizCardRepository: quizCardRepository,
        deckPremiumManager: deckPremiumManager,
      );

  setUp(() {
    deckRepository = MockDeckRepository();
    quizCardRepository = MockQuizCardRepository();
    deckPremiumManager = MockDeckPremiumManager();
  });

  test('generate produces content with cards and a title', () async {
    final cubit = buildCubit();

    await cubit.generate('the solar system', title: 'Space');

    final state = cubit.state;
    expect(state, isA<AiGenerateContentState>());
    final content = state as AiGenerateContentState;
    expect(content.title, 'Space');
    expect(content.cards, isNotEmpty);
    expect(cubit.hasContent, isTrue);
  });

  test('refine keeps existing cards and adds one more', () async {
    final cubit = buildCubit();
    await cubit.generate('history');
    final before = (cubit.state as AiGenerateContentState).cards.length;

    await cubit.refine('make it harder');

    final after = (cubit.state as AiGenerateContentState).cards.length;
    expect(after, before + 1);
  });

  test('add and delete card mutate the list', () async {
    final cubit = buildCubit();
    await cubit.generate('geography');
    final content = cubit.state as AiGenerateContentState;
    final initialCount = content.cards.length;

    cubit.addCard();
    expect((cubit.state as AiGenerateContentState).cards.length,
        initialCount + 1);

    final firstId =
        (cubit.state as AiGenerateContentState).cards.first.localId;
    cubit.deleteCard(firstId);
    expect(
        (cubit.state as AiGenerateContentState).cards.length, initialCount);
  });

  test('updateCard edits silently without changing card count', () async {
    final cubit = buildCubit();
    await cubit.generate('math');
    final card = (cubit.state as AiGenerateContentState).cards.first;

    cubit.updateCard(card.localId, question: 'Q?', answer: 'A!');
    cubit.addCard(); // trigger an emit so we can read the current model

    final updated = (cubit.state as AiGenerateContentState)
        .cards
        .firstWhere((c) => c.localId == card.localId);
    expect(updated.question, 'Q?');
    expect(updated.answer, 'A!');
  });

  test('save persists deck + cards and emits Saved when allowed', () async {
    when(() => deckPremiumManager.canAddDeck())
        .thenAnswer((_) async => true);
    when(() => deckRepository.saveDeck(any())).thenAnswer((_) async => 42);
    when(() => quizCardRepository.saveQuizCards(any(), any()))
        .thenAnswer((_) async => [1, 2, 3, 4]);

    final cubit = buildCubit();
    await cubit.generate('biology', title: 'Cells');

    final expectation = expectLater(
      cubit.stream,
      emitsThrough(isA<AiGenerateSavedState>()),
    );
    await cubit.save();
    await expectation;

    verify(() => deckRepository.saveDeck('Cells')).called(1);
    verify(() => quizCardRepository.saveQuizCards(any(), 42)).called(1);
  });

  test('save emits SaveBlocked when premium limit reached', () async {
    when(() => deckPremiumManager.canAddDeck())
        .thenAnswer((_) async => false);

    final cubit = buildCubit();
    await cubit.generate('chemistry');

    final expectation = expectLater(
      cubit.stream,
      emitsThrough(isA<AiGenerateSaveBlockedState>()),
    );
    await cubit.save();
    await expectation;

    verifyNever(() => deckRepository.saveDeck(any()));
  });
}
