import 'package:poc_ai_quiz/data/db/database.dart';

class DeckDataBaseRepository {
  final AppDatabase appDatabase;

  DeckDataBaseRepository(this.appDatabase);

  Future<List<DeckTableData>> fetchAllDecks() async {
    return await appDatabase.select(appDatabase.deckTable).get();
  }

  Future<bool> saveDeck(String deckName) async {
    final result = await appDatabase.into(appDatabase.deckTable).insert(
          DeckTableCompanion.insert(
            title: deckName,
          ),
        );
    return result != -1;
  }
}
