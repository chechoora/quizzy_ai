import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:poc_ai_quiz/domain/import_export/model.dart';

class ImportService {
  Future<List<PlainDeckModel>?> importDecksFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    return parseDecksFromJson(jsonString);
  }

  Future<List<PlainCardModel>?> importCardsFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    return parseCardsFromJson(jsonString);
  }

  Future<List<PlainDeckModel>?> importDecksFromClipboard() async {
    final text = await _getClipboardText();
    if (text == null) return null;
    return parseDecksFromJson(text);
  }

  Future<List<PlainCardModel>?> importCardsFromClipboard() async {
    final text = await _getClipboardText();
    if (text == null) return null;
    return parseCardsFromJson(text);
  }

  Future<String?> _getClipboardText() async {
    final clipboardData = await Clipboard.getData('text/plain');
    final text = clipboardData?.text;
    if (text == null || text.isEmpty) return null;
    return text;
  }

  List<PlainDeckModel> parseDecksFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final decksJson = data['decks'] as List<dynamic>;

    return decksJson.map((deckJson) {
      final deckMap = deckJson as Map<String, dynamic>;
      final cardsJson = deckMap['cards'] as List<dynamic>;

      return PlainDeckModel(
        title: deckMap['title'] as String,
        cards: cardsJson
            .map((cardJson) => PlainCardModel(
                  question:
                      (cardJson as Map<String, dynamic>)['question'] as String,
                  answer: cardJson['answer'] as String,
                ))
            .toList(),
      );
    }).toList();
  }

  List<PlainCardModel> parseCardsFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final cardsJson = data['cards'] as List<dynamic>;

    return cardsJson
        .map((cardJson) => PlainCardModel(
              question:
                  (cardJson as Map<String, dynamic>)['question'] as String,
              answer: cardJson['answer'] as String,
            ))
        .toList();
  }
}