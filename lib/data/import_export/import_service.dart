import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:poc_ai_quiz/domain/exception/import_export_exception.dart';
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
    final data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) throw const ImportExportException();
    final decksJson = data['decks'];
    if (decksJson is! List<dynamic>) throw const ImportExportException();

    return decksJson.map((deckJson) {
      if (deckJson is! Map<String, dynamic>) throw const ImportExportException();
      final cardsJson = deckJson['cards'];
      if (cardsJson is! List<dynamic>) throw const ImportExportException();
      final title = deckJson['title'];
      if (title is! String) throw const ImportExportException();

      return PlainDeckModel(
        title: title,
        cards: cardsJson.map((cardJson) {
          if (cardJson is! Map<String, dynamic>) {
            throw const ImportExportException();
          }
          final question = cardJson['question'];
          final answer = cardJson['answer'];
          if (question is! String || answer is! String) {
            throw const ImportExportException();
          }
          return PlainCardModel(question: question, answer: answer);
        }).toList(),
      );
    }).toList();
  }

  List<PlainCardModel> parseCardsFromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) throw const ImportExportException();
    final cardsJson = data['cards'];
    if (cardsJson is! List<dynamic>) throw const ImportExportException();

    return cardsJson.map((cardJson) {
      if (cardJson is! Map<String, dynamic>) {
        throw const ImportExportException();
      }
      final question = cardJson['question'];
      final answer = cardJson['answer'];
      if (question is! String || answer is! String) {
        throw const ImportExportException();
      }
      return PlainCardModel(question: question, answer: answer);
    }).toList();
  }
}
