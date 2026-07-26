import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/domain/ai_gen/ai_gen_service.dart';
import 'package:poc_ai_quiz/domain/analytics/analytics_service.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/view/deck_edit/cubit/cubit.dart';

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockInAppPurchaseService extends Mock implements InAppPurchaseService {}

class MockAiGenService extends Mock implements AiGenService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  const deckItem = DeckItem(id: 42, title: 'Space', isArchive: false);

  late MockQuizCardRepository quizCardRepository;
  late MockInAppPurchaseService inAppPurchaseService;
  late MockAiGenService aiGenService;
  late MockAnalyticsService analyticsService;

  setUpAll(() {
    registerFallbackValue(<PlainCardModel>[]);
    registerFallbackValue(const AiGenRequest(prompt: ''));
  });

  DeckEditCubit buildCubit({bool isSubscriptionOnly = false}) => DeckEditCubit(
        aiGenService: aiGenService,
        deckItem: deckItem,
        quizCardRepository: quizCardRepository,
        inAppPurchaseService: inAppPurchaseService,
        analyticsService: analyticsService,
        isSubscriptionOnly: isSubscriptionOnly,
      );

  setUp(() {
    quizCardRepository = MockQuizCardRepository();
    inAppPurchaseService = MockInAppPurchaseService();
    aiGenService = MockAiGenService();
    analyticsService = MockAnalyticsService();
    when(() => analyticsService.track(any(), properties: any(named: 'properties')))
        .thenAnswer((_) async {});

    // Generation returns a fresh set; refinement returns the cards it was
    // given plus one, so tests can tell the two paths apart.
    when(() => aiGenService.generate(any())).thenAnswer((invocation) async {
      final request = invocation.positionalArguments.first as AiGenRequest;
      final cards = request.isRefinement
          ? [
              ...request.currentCards,
              PlainCardModel(question: 'Extra?', answer: 'Extra!'),
            ]
          : [
              PlainCardModel(question: 'Q1?', answer: 'A1'),
              PlainCardModel(question: 'Q2?', answer: 'A2'),
              PlainCardModel(question: 'Q3?', answer: 'A3'),
            ];
      return PlainDeckModel(title: request.deckTitle ?? 'Deck', cards: cards);
    });
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

  test('init reflects the AI entitlement in the content state', () async {
    when(() => quizCardRepository.fetchQuizCardItem(deckItem.id))
        .thenAnswer((_) async => []);
    when(() => inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards))
        .thenAnswer((_) async => false);

    final freeCubit = buildCubit();
    await freeCubit.init();
    expect((freeCubit.state as AiGenerateContentState).isPremium, isFalse);
    expect(freeCubit.isPremium, isFalse);

    when(() => inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards))
        .thenAnswer((_) async => true);

    final premiumCubit = buildCubit();
    await premiumCubit.init();
    expect((premiumCubit.state as AiGenerateContentState).isPremium, isTrue);
  });

  test(
      'init checks the quizzyAi subscription when the flavor is '
      'subscription-only', () async {
    when(() => quizCardRepository.fetchQuizCardItem(deckItem.id))
        .thenAnswer((_) async => []);
    when(() => inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.quizzyAi))
        .thenAnswer((_) async => true);

    final cubit = buildCubit(isSubscriptionOnly: true);
    expect(cubit.unlockFeature, InAppPurchaseFeature.quizzyAi);

    await cubit.init();
    expect(cubit.isPremium, isTrue);
    verifyNever(() => inAppPurchaseService
        .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards));
  });

  test('onAiUnlocked flips the mode to premium', () async {
    when(() => quizCardRepository.fetchQuizCardItem(deckItem.id))
        .thenAnswer((_) async => []);
    when(() => inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards))
        .thenAnswer((_) async => false);

    final cubit = buildCubit();
    await cubit.init();
    expect(cubit.isPremium, isFalse);

    cubit.onAiUnlocked();

    expect(cubit.isPremium, isTrue);
    expect((cubit.state as AiGenerateContentState).isPremium, isTrue);
  });

  test('save writes cards to the existing deck and emits Saved', () async {
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
}
