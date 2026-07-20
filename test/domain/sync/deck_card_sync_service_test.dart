import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/sync/sync_tombstone_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/cards_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/decks_repository.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/new_remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_card.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/remote_deck_with_cards.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/quizzy_backend_exception.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

class MockDecksRepository extends Mock implements DecksRepository {}

class MockCardsRepository extends Mock implements CardsRepository {}

class MockSyncTombstoneRepository extends Mock
    implements SyncTombstoneRepository {}

DateTime _now() => DateTime(2026, 1, 1);

RemoteDeck _remoteDeck(String id, {String title = 'Deck', bool archived = false}) {
  return RemoteDeck(
    id: id,
    userId: 'user-1',
    title: title,
    isArchived: archived,
    createdAt: _now(),
    updatedAt: _now(),
  );
}

RemoteDeckWithCards _remoteDeckWithCards(String id, {String title = 'Deck'}) {
  return RemoteDeckWithCards(
    id: id,
    userId: 'user-1',
    title: title,
    isArchived: false,
    createdAt: _now(),
    updatedAt: _now(),
    cards: const [],
  );
}

RemoteCard _remoteCard(String id, String deckId,
    {String question = 'Q', String answer = 'A'}) {
  return RemoteCard(
    id: id,
    deckId: deckId,
    question: question,
    answer: answer,
    isArchived: false,
    createdAt: _now(),
    updatedAt: _now(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NewRemoteDeck(title: ''));
  });

  late MockDeckRepository deckRepository;
  late MockQuizCardRepository quizCardRepository;
  late MockDecksRepository decksRepository;
  late MockCardsRepository cardsRepository;
  late MockSyncTombstoneRepository tombstoneRepository;
  late DeckCardSyncService service;

  setUp(() {
    deckRepository = MockDeckRepository();
    quizCardRepository = MockQuizCardRepository();
    decksRepository = MockDecksRepository();
    cardsRepository = MockCardsRepository();
    tombstoneRepository = MockSyncTombstoneRepository();
    service = DeckCardSyncService(
      deckRepository: deckRepository,
      quizCardRepository: quizCardRepository,
      decksRepository: decksRepository,
      cardsRepository: cardsRepository,
      tombstoneRepository: tombstoneRepository,
      logger: Logger.withTag('test'),
    );

    // Defaults so every push/pull test only needs to stub what it cares
    // about.
    when(() => tombstoneRepository.fetchTombstones(any()))
        .thenAnswer((_) async => const []);
    when(() => deckRepository.fetchDirtyDecks()).thenAnswer((_) async => const []);
    when(() => quizCardRepository.fetchDirtyCards())
        .thenAnswer((_) async => const []);
    when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const []);
    when(() => deckRepository.fetchSyncedDecks())
        .thenAnswer((_) async => const []);
  });

  group('pushLocalChanges', () {
    test('creates a deck before pushing its cards', () async {
      const deck = DeckItem(id: 1, title: 'Deck', isArchive: false);
      const card = QuizCardItem(
        id: 1,
        deckId: 1,
        questionText: 'Q',
        answerText: 'A',
        isArchive: false,
      );

      when(() => deckRepository.fetchDirtyDecks())
          .thenAnswer((_) async => const [deck]);
      when(() => decksRepository.createDeck(any()))
          .thenAnswer((_) async => _remoteDeckWithCards('rd1'));
      when(() => deckRepository.markDeckSynced(1, 'rd1'))
          .thenAnswer((_) async {});
      when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const [
            DeckItem(
                id: 1,
                title: 'Deck',
                isArchive: false,
                remoteId: 'rd1',
                isDirty: false),
          ]);
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => const [card]);
      when(() => decksRepository.addCard('rd1', question: 'Q', answer: 'A'))
          .thenAnswer((_) async => _remoteCard('rc1', 'rd1'));
      when(() => quizCardRepository.markCardSynced(1, 'rc1'))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.decksPushed, 1);
      expect(result.cardsPushed, 1);
      expect(result.failures, 0);
      verifyInOrder([
        () => decksRepository.createDeck(any()),
        () => decksRepository.addCard('rd1', question: 'Q', answer: 'A'),
      ]);
    });

    test('skips a card whose deck is not yet synced', () async {
      const card = QuizCardItem(
        id: 2,
        deckId: 5,
        questionText: 'Q',
        answerText: 'A',
        isArchive: false,
      );
      when(() => deckRepository.fetchDecks()).thenAnswer((_) async => const [
            DeckItem(id: 5, title: 'Deck', isArchive: false),
          ]);
      when(() => quizCardRepository.fetchDirtyCards())
          .thenAnswer((_) async => const [card]);

      final result = await service.pushLocalChanges();

      expect(result.cardsPushed, 0);
      expect(result.failures, 0);
      verifyNever(() => decksRepository.addCard(any(), question: any(named: 'question'), answer: any(named: 'answer')));
      verifyNever(() => quizCardRepository.markCardSynced(any(), any()));
    });

    test('a failing deck does not stop the next deck from being pushed',
        () async {
      const deckA = DeckItem(id: 1, title: 'A', isArchive: false);
      const deckB = DeckItem(id: 2, title: 'B', isArchive: false);
      when(() => deckRepository.fetchDirtyDecks())
          .thenAnswer((_) async => const [deckA, deckB]);

      var call = 0;
      when(() => decksRepository.createDeck(any())).thenAnswer((_) async {
        call++;
        if (call == 1) throw Exception('network error');
        return _remoteDeckWithCards('rdB');
      });
      when(() => deckRepository.markDeckSynced(2, 'rdB'))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.decksPushed, 1);
      expect(result.failures, 1);
      verifyNever(() => deckRepository.markDeckSynced(1, any()));
      verify(() => deckRepository.markDeckSynced(2, 'rdB')).called(1);
    });

    test(
        'tombstone push purges on success and on 404, retries on other errors',
        () async {
      final t1 = SyncTombstoneTableData(
          id: 1, entityType: 'deck', remoteId: 'd1', createdAt: _now());
      final t2 = SyncTombstoneTableData(
          id: 2, entityType: 'deck', remoteId: 'd2', createdAt: _now());
      final t3 = SyncTombstoneTableData(
          id: 3, entityType: 'deck', remoteId: 'd3', createdAt: _now());
      when(() => tombstoneRepository.fetchTombstones('deck'))
          .thenAnswer((_) async => [t1, t2, t3]);
      when(() => tombstoneRepository.fetchTombstones('card'))
          .thenAnswer((_) async => const []);

      when(() => decksRepository.deleteDeck('d1')).thenAnswer((_) async {});
      when(() => decksRepository.deleteDeck('d2')).thenThrow(
          QuizzyBackendException('not found', statusCode: 404));
      when(() => decksRepository.deleteDeck('d3'))
          .thenThrow(QuizzyBackendException('server error', statusCode: 500));
      when(() => tombstoneRepository.deleteTombstone(any()))
          .thenAnswer((_) async {});

      final result = await service.pushLocalChanges();

      expect(result.deckTombstonesPurged, 2);
      expect(result.failures, 1);
      verify(() => tombstoneRepository.deleteTombstone(1)).called(1);
      verify(() => tombstoneRepository.deleteTombstone(2)).called(1);
      verifyNever(() => tombstoneRepository.deleteTombstone(3));
    });
  });

  group('pullRemoteChanges', () {
    test('upserts decks and cards by remoteId', () async {
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1')]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 10);
      when(() => decksRepository.listCards('d1'))
          .thenAnswer((_) async => [_remoteCard('c1', 'd1')]);
      when(() => quizCardRepository.upsertCardFromRemote(
            remoteId: 'c1',
            deckId: 10,
            question: 'Q',
            answer: 'A',
            isArchive: false,
          )).thenAnswer((_) async => 100);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(10))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.decksUpserted, 1);
      expect(result.cardsUpserted, 1);
      expect(result.failures, 0);
    });

    test('deletes a local synced deck missing from listDecks (remote-wins)',
        () async {
      when(() => decksRepository.listDecks()).thenAnswer((_) async => const []);
      when(() => deckRepository.fetchSyncedDecks()).thenAnswer((_) async => const [
            DeckItem(
                id: 7,
                title: 'Gone',
                isArchive: false,
                remoteId: 'gone',
                isDirty: true),
          ]);
      when(() => deckRepository.deleteDeckByRemoteId('gone'))
          .thenAnswer((_) async => true);

      final result = await service.pullRemoteChanges();

      expect(result.decksDeletedLocally, 1);
      verify(() => deckRepository.deleteDeckByRemoteId('gone')).called(1);
    });

    test('continues to the next deck when one deck\'s listCards throws',
        () async {
      when(() => decksRepository.listDecks())
          .thenAnswer((_) async => [_remoteDeck('d1'), _remoteDeck('d2')]);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd1',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 1);
      when(() => deckRepository.upsertDeckFromRemote(
            remoteId: 'd2',
            title: 'Deck',
            isArchive: false,
          )).thenAnswer((_) async => 2);
      when(() => decksRepository.listCards('d1')).thenThrow(Exception('boom'));
      when(() => decksRepository.listCards('d2')).thenAnswer((_) async => const []);
      when(() => quizCardRepository.fetchSyncedCardsForDeck(any()))
          .thenAnswer((_) async => const []);

      final result = await service.pullRemoteChanges();

      expect(result.decksUpserted, 2);
      expect(result.failures, 1);
    });
  });
}
