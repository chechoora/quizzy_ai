import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';

void main() {
  final dataBaseRepository = MockDeckDataBaseRepository();
  final deckRepository = DeckRepository(
    dataBaseRepository: dataBaseRepository,
    deckDatBaseMapper: DeckDatBaseMapper(),
  );
  group(
    'fetch data',
    () {
      test('fetch all items', () async {
        when(() => dataBaseRepository.fetchAllDecks()).thenAnswer(
          (invocation) => Future.value(
            const <DeckWithCardCount>[
              (
                deck: DeckTableData(
                  id: 1,
                  title: 'title1',
                  isArchive: false,
                  isDirty: false,
                ),
                cardCount: 0,
              ),
              (
                deck: DeckTableData(
                  id: 2,
                  title: 'title2',
                  isArchive: false,
                  isDirty: false,
                ),
                cardCount: 2,
              ),
              (
                deck: DeckTableData(
                  id: 3,
                  title: 'title3',
                  isArchive: false,
                  isDirty: false,
                ),
                cardCount: 5,
              ),
            ],
          ),
        );
        final results = await deckRepository.fetchDecks();
        expect(results.length, 3);
        expect(results[1].cardCount, 2);
        expect(results[2].cardCount, 5);
      });
      test('fetch zero items', () async {
        when(() => dataBaseRepository.fetchAllDecks()).thenAnswer(
          (invocation) => Future.value(
            const <DeckWithCardCount>[],
          ),
        );
        final results = await deckRepository.fetchDecks();
        expect(results.length, 0);
      });
    },
  );
}

class MockDeckDataBaseRepository extends Mock implements DeckDataBaseRepository {}
