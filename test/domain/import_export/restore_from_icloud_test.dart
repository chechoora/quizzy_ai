import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/data/import_export/import_service.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
import 'package:poc_ai_quiz/domain/icloud_backup/icloud_backup_service.dart';
import 'package:poc_ai_quiz/domain/import_export/import_export_service.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';
import 'package:poc_ai_quiz/domain/in_app_purchase/in_app_purchase_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/remote_config/remote_config_service.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockExportService extends Mock implements ExportService {}

class MockInAppPurchaseService extends Mock implements InAppPurchaseService {}

class MockIcloudBackupService extends Mock implements IcloudBackupService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  setUpAll(() {
    registerFallbackValue(<PlainCardModel>[]);
    registerFallbackValue(PlainCardModel(question: '', answer: ''));
  });

  late MockDeckRepository deckRepository;
  late MockQuizCardRepository quizCardRepository;
  late MockInAppPurchaseService inAppPurchaseService;
  late MockIcloudBackupService icloudBackupService;
  late MockRemoteConfigService remoteConfigService;
  late ImportExportService service;

  setUp(() {
    deckRepository = MockDeckRepository();
    quizCardRepository = MockQuizCardRepository();
    inAppPurchaseService = MockInAppPurchaseService();
    icloudBackupService = MockIcloudBackupService();
    remoteConfigService = MockRemoteConfigService();
    when(() => remoteConfigService.deckLimit).thenReturn(3);
    when(() => remoteConfigService.quizCardLimit).thenReturn(8);
    service = ImportExportService(
      importService: ImportService(),
      exportService: MockExportService(),
      deckRepository: deckRepository,
      quizCardRepository: quizCardRepository,
      inAppPurchaseService: inAppPurchaseService,
      icloudBackupService: icloudBackupService,
      remoteConfigService: remoteConfigService,
      isSubscriptionOnly: false,
    );
  });

  void stubPremium(bool premium) {
    when(() => inAppPurchaseService
            .isFeaturePurchased(InAppPurchaseFeature.unlimitedDecksCards))
        .thenAnswer((_) async => premium);
  }

  test('returns null when there is no backup', () async {
    when(() => icloudBackupService.fetchBackupPayload())
        .thenAnswer((_) async => null);

    final result = await service.restoreFromICloud();

    expect(result, isNull);
    verifyNever(() => deckRepository.saveDeckWithUid(any(), any()));
  });

  test('inserts a new deck preserving uids', () async {
    when(() => icloudBackupService.fetchBackupPayload()).thenAnswer(
      (_) async =>
          '{"decks":[{"id":100,"title":"Deck","cards":[{"id":200,"question":"q","answer":"a"}]}]}',
    );
    when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const []);
    stubPremium(true);
    when(() => deckRepository.saveDeckWithUid('Deck', 100))
        .thenAnswer((_) async => 1);
    when(() => quizCardRepository.saveCardsWithUid(any(), 1))
        .thenAnswer((_) async => const [10]);

    final result = await service.restoreFromICloud();

    expect(result, 1);
    verify(() => deckRepository.saveDeckWithUid('Deck', 100)).called(1);
    final captured = verify(
      () => quizCardRepository.saveCardsWithUid(captureAny(), 1),
    ).captured.single as List<PlainCardModel>;
    expect(captured.single.uid, 200);
  });

  test('dedupes into an existing deck: updates existing, inserts new', () async {
    when(() => icloudBackupService.fetchBackupPayload()).thenAnswer(
      (_) async =>
          '{"decks":[{"id":100,"title":"Deck","cards":[{"id":200,"question":"q1","answer":"a1"},{"id":201,"question":"q2","answer":"a2"}]}]}',
    );
    when(() => deckRepository.fetchDecks()).thenAnswer(
      (_) async => const [
        DeckItem(id: 1, uid: 100, title: 'Deck', isArchive: false),
      ],
    );
    stubPremium(true);
    when(() => quizCardRepository.fetchCardUids(1))
        .thenAnswer((_) async => {200});
    when(() => quizCardRepository.updateCardByUid(1, any()))
        .thenAnswer((_) async => true);
    when(() => quizCardRepository.saveCardsWithUid(any(), 1))
        .thenAnswer((_) async => const [11]);

    final result = await service.restoreFromICloud();

    expect(result, 1);
    // Existing card (uid 200) is updated, not re-inserted.
    final updated = verify(
      () => quizCardRepository.updateCardByUid(1, captureAny()),
    ).captured.single as PlainCardModel;
    expect(updated.uid, 200);
    // Only the new card (uid 201) is inserted.
    final inserted = verify(
      () => quizCardRepository.saveCardsWithUid(captureAny(), 1),
    ).captured.single as List<PlainCardModel>;
    expect(inserted.single.uid, 201);
    verifyNever(() => deckRepository.saveDeckWithUid(any(), any()));
  });

  test('enforces deck limit for non-premium users', () async {
    when(() => icloudBackupService.fetchBackupPayload()).thenAnswer(
      (_) async =>
          '{"decks":[{"id":1,"title":"A","cards":[]},{"id":2,"title":"B","cards":[]},{"id":3,"title":"C","cards":[]},{"id":4,"title":"D","cards":[]}]}',
    );
    when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const []);
    stubPremium(false);

    expect(
      () => service.restoreFromICloud(),
      throwsA(isA<ImportLimitExceededException>()),
    );
  });
}
