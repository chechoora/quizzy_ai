import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

class ImportService {
  Future<List<DeckImportModel>?> importDecksFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final decksJson = data['decks'] as List<dynamic>;

    return decksJson.map((deckJson) {
      final deckMap = deckJson as Map<String, dynamic>;
      final cardsJson = deckMap['cards'] as List<dynamic>;

      return DeckImportModel(
        title: deckMap['title'] as String,
        cards: cardsJson
            .map((cardJson) => CardImportModel(
                  question:
                      (cardJson as Map<String, dynamic>)['question'] as String,
                  answer: cardJson['answer'] as String,
                ))
            .toList(),
      );
    }).toList();
  }
}

class DeckImportModel {
  final String title;
  final List<CardImportModel> cards;

  DeckImportModel({
    required this.title,
    required this.cards,
  });
}

class CardImportModel {
  final String question;
  final String answer;

  CardImportModel({
    required this.question,
    required this.answer,
  });
}