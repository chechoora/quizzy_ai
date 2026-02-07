import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class ImportService {
  Future<List<DeckImportModel>?> importDecksFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    return parseDecksFromJson(jsonString);
  }

  Future<List<CardImportModel>?> importCardsFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    return parseCardsFromJson(jsonString);
  }

  Future<List<DeckImportModel>?> importDecksFromClipboard() async {
    final text = await _getClipboardText();
    if (text == null) return null;
    return parseDecksFromJson(text);
  }

  Future<List<CardImportModel>?> importCardsFromClipboard() async {
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

  List<DeckImportModel> parseDecksFromJson(String jsonString) {
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

  List<CardImportModel> parseCardsFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final cardsJson = data['cards'] as List<dynamic>;

    return cardsJson
        .map((cardJson) => CardImportModel(
              question:
                  (cardJson as Map<String, dynamic>)['question'] as String,
              answer: cardJson['answer'] as String,
            ))
        .toList();
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