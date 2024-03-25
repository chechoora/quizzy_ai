import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/model/deck_item.dart';

class DeckDatBaseMapper {
  List<DeckItem> mapToDeckItemList(List<DeckTableData> dataBaseDeckItems) {
    return dataBaseDeckItems
        .map(
          (e) => DeckItem(
            id: e.id,
            title: e.title,
            isArchive: e.isArchive,
          ),
        )
        .toList();
  }
}
