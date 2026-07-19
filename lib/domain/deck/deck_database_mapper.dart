import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/domain/deck/model/deck_item.dart';

class DeckDatBaseMapper {
  List<DeckItem> mapToDeckItemList(List<DeckTableData> dataBaseDeckItems) {
    return dataBaseDeckItems
        .map(
          (e) => DeckItem(
            id: e.id,
            uid: e.uid,
            title: e.title,
            isArchive: e.isArchive,
            remoteId: e.remoteId,
            isDirty: e.isDirty,
          ),
        )
        .toList();
  }
}
