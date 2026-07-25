import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_category.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/model/public_deck_summary.dart';
import 'package:poc_ai_quiz/domain/quizzy_backend/public_decks_repository.dart';
import 'package:poc_ai_quiz/util/logger.dart';
import 'package:poc_ai_quiz/util/unique_emit.dart';

class PublicDecksCubit extends Cubit<PublicDecksState> {
  PublicDecksCubit({
    required this.publicDecksRepository,
    required this.logger,
  }) : super(PublicDecksLoadingState());

  final PublicDecksRepository publicDecksRepository;
  final Logger logger;

  static const _searchDebounce = Duration(milliseconds: 400);

  List<PublicCategory> _categories = [];
  PublicCategory? _selectedCategory;
  String? _searchQuery;
  Timer? _searchDebounceTimer;
  final List<PublicDeckSummary> _decks = [];

  Future<void> loadInitial() async {
    logger.d('loadInitial: starting');
    emit(PublicDecksLoadingState());
    try {
      _categories = await publicDecksRepository.listCategories();
    } catch (e, stackTrace) {
      logger.e('loadInitial: failed to load categories',
          ex: e, stacktrace: stackTrace);
      emit(PublicDecksErrorState());
      _emitData();
      return;
    }
    logger.i('loadInitial: loaded ${_categories.length} categories');
    await _fetchDecks();
  }

  Future<void> selectCategory(PublicCategory? category) async {
    logger.d('selectCategory: category=${category?.slug}');
    _selectedCategory = category;
    await _fetchDecks();
  }

  void onSearchChanged(String query) {
    final normalized = query.trim().isEmpty ? null : query.trim();
    logger.d('onSearchChanged: query=$normalized');
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      _searchQuery = normalized;
      unawaited(_fetchDecks());
    });
  }

  Future<void> _fetchDecks() async {
    emit(PublicDecksLoadingState());
    try {
      final decks = await publicDecksRepository.listPublicDecks(
        category: _selectedCategory?.slug,
        q: _searchQuery,
      );
      _decks
        ..clear()
        ..addAll(decks);
      logger.i('_fetchDecks: success, ${_decks.length} decks '
          '(category=${_selectedCategory?.slug}, q=$_searchQuery)');
      _emitData();
    } catch (e, stackTrace) {
      logger.e('_fetchDecks: failed', ex: e, stacktrace: stackTrace);
      emit(PublicDecksErrorState());
      _emitData();
    }
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  void _emitData() {
    emit(
      PublicDecksDataState(
        categories: List.unmodifiable(_categories),
        selectedCategory: _selectedCategory,
        decks: List.unmodifiable(_decks),
      ),
    );
  }
}

abstract class PublicDecksState extends Equatable {
  const PublicDecksState();
}

abstract class BuilderState extends PublicDecksState {
  const BuilderState();
}

abstract class ListenerState extends PublicDecksState with UniqueEmit {
  ListenerState();

  @override
  List<Object?> get props => [...uniqueProps];
}

class PublicDecksLoadingState extends BuilderState {
  @override
  List<Object?> get props => [];
}

class PublicDecksDataState extends BuilderState {
  const PublicDecksDataState({
    required this.categories,
    required this.selectedCategory,
    required this.decks,
  });

  final List<PublicCategory> categories;
  final PublicCategory? selectedCategory;
  final List<PublicDeckSummary> decks;

  @override
  List<Object?> get props => [categories, selectedCategory, decks];
}

class PublicDecksErrorState extends ListenerState {}
