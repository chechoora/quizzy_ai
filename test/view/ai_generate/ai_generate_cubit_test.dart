import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/ai_gen/mock_ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/view/ai_generate/cubit/ai_generate_cubit.dart';

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockQuizCardPremiumManager extends Mock
    implements QuizCardPremiumManager {}

void main() {
  const deckItem = DeckItem(id: 42, title: 'Space', isArchive: false);

  late MockQuizCardRepository quizCardRepository;
  late MockQuizCardPremiumManager quizCardPremiumManager;

  setUpAll(() {
    registerFallbackValue(<PlainCardModel>[]);
  });

  AiGenerateCubit buildCubit() => AiGenerateCubit(
        aiGenService: MockAiGenService(),
        deckItem: deckItem,
        quizCardRepository: quizCardRepository,
        quizCardPremiumManager: quizCardPremiumManager,
      );

  setUp(() {
    quizCardRepository = MockQuizCardRepository();
    quizCardPremiumManager = MockQuizCardPremiumManager();
  });

  test('generate produces content with cards', () async {
    final cubit = buildCubit();

    await cubit.generate('the solar system');

    final state = cubit.state;
    expect(state, isA<AiGenerateContentState>());
    final content = state as AiGenerateContentState;
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

  test('save appends cards to the existing deck and emits Saved', () async {
    when(() => quizCardPremiumManager.canAddQuizCard(deckItem))
        .thenAnswer((_) async => true);
    when(() => quizCardRepository.saveQuizCards(any(), any()))
        .thenAnswer((_) async => [1, 2, 3, 4]);

    final cubit = buildCubit();
    await cubit.generate('biology');

    final expectation = expectLater(
      cubit.stream,
      emitsThrough(isA<AiGenerateSavedState>()),
    );
    await cubit.save();
    await expectation;

    // Cards are saved into the existing deck; no new deck is created.
    verify(() => quizCardRepository.saveQuizCards(any(), deckItem.id))
        .called(1);
  });

  test('save emits SaveBlocked when card limit reached', () async {
    when(() => quizCardPremiumManager.canAddQuizCard(deckItem))
        .thenAnswer((_) async => false);

    final cubit = buildCubit();
    await cubit.generate('chemistry');

    final expectation = expectLater(
      cubit.stream,
      emitsThrough(isA<AiGenerateSaveBlockedState>()),
    );
    await cubit.save();
    await expectation;

    verifyNever(() => quizCardRepository.saveQuizCards(any(), any()));
  });
}
