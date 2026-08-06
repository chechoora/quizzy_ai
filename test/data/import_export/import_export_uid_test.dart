import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/import_export/export_service.dart';
import 'package:poc_ai_quiz/data/import_export/import_service.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';

class MockQuizCardRepository extends Mock implements QuizCardRepository {}

void main() {
  group('ImportService uid parsing', () {
    final service = ImportService();

    test('reads deck and card ids into uid when present', () {
      const json = '''
      {"decks":[{"id":111,"title":"Deck","cards":[{"id":222,"question":"q","answer":"a"}]}]}
      ''';
      final decks = service.parseDecksFromJson(json);
      expect(decks.single.uid, 111);
      expect(decks.single.cards.single.uid, 222);
    });

    test('leaves uid null when id is absent (user-authored import)', () {
      const json =
          '{"decks":[{"title":"Deck","cards":[{"question":"q","answer":"a"}]}]}';
      final decks = service.parseDecksFromJson(json);
      expect(decks.single.uid, isNull);
      expect(decks.single.cards.single.uid, isNull);
    });

    test('parseCardsFromJson reads card id into uid', () {
      const json = '{"cards":[{"id":42,"question":"q","answer":"a"}]}';
      final cards = service.parseCardsFromJson(json);
      expect(cards.single.uid, 42);
    });
  });

  group('ExportService includes ids', () {
    late MockQuizCardRepository quizCardRepository;
    late ExportService exportService;

    setUp(() {
      quizCardRepository = MockQuizCardRepository();
      exportService = ExportService(quizCardRepository: quizCardRepository);
    });

    test('emits deck.uid and card.uid as id fields', () async {
      when(() => quizCardRepository.fetchQuizCardItem(1)).thenAnswer(
        (_) async => const [
          QuizCardItem(
            id: 10,
            uid: 999,
            deckId: 1,
            questionText: 'q',
            answerText: 'a',
            isArchive: false,
          ),
        ],
      );

      final json = await exportService.exportDecksToJson(const [
        DeckItem(id: 1, uid: 555, title: 'Deck', isArchive: false, cardCount: 0),
      ]);

      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final deck = (decoded['decks'] as List).single as Map<String, dynamic>;
      expect(deck['id'], 555);
      final card = (deck['cards'] as List).single as Map<String, dynamic>;
      expect(card['id'], 999);
    });
  });
}
