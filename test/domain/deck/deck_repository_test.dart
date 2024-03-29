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
            const <DeckTableData>[
              DeckTableData(
                id: 1,
                title: 'title1',
                isArchive: false,
              ),
              DeckTableData(
                id: 2,
                title: 'title2',
                isArchive: false,
              ),
              DeckTableData(
                id: 3,
                title: 'title3',
                isArchive: false,
              ),
            ],
          ),
        );
        final results = await deckRepository.fetchDecks();
        expect(results.length, 3);
      });
      test('fetch zero items', () async {
        when(() => dataBaseRepository.fetchAllDecks()).thenAnswer(
          (invocation) => Future.value(
            const <DeckTableData>[],
          ),
        );
        final results = await deckRepository.fetchDecks();
        expect(results.length, 0);
      });
    },
  );
}

class MockDeckDataBaseRepository extends Mock implements DeckDataBaseRepository {}
