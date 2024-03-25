import 'package:equatable/equatable.dart';

class DeckItem extends Equatable {
  final int id;
  final String title;
  final bool isArchive;

  const DeckItem({
    required this.id,
    required this.title,
    required this.isArchive,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        isArchive,
      ];
}

class QuizCardItem extends Equatable {
  final int id;
  final int deckId;
  final String questionText;
  final String answerText;
  final bool isArchive;

  const QuizCardItem({
    required this.id,
    required this.deckId,
    required this.questionText,
    required this.answerText,
    required this.isArchive,
  });

  @override
  List<Object?> get props => [
        id,
        deckId,
        questionText,
        answerText,
        isArchive,
      ];
}

mixin PremiumInfo {
  late final bool _isLocked;

  bool get isLocked => _isLocked;
}

class DeckItemWithPremium extends DeckItem with PremiumInfo {
  DeckItemWithPremium({
    required super.id,
    required super.title,
    required super.isArchive,
    required bool isLocked,
  }) {
    _isLocked = isLocked;
  }

  factory DeckItemWithPremium.fromDeck({
    required DeckItem deckItem,
    required bool isLocked,
  }) {
    return DeckItemWithPremium(
      id: deckItem.id,
      title: deckItem.title,
      isArchive: deckItem.isArchive,
      isLocked: isLocked,
    );
  }

  @override
  List<Object?> get props => super.props..add(_isLocked);
}

class QuizCardItemWithPremium extends QuizCardItem with PremiumInfo {
  QuizCardItemWithPremium({
    required super.id,
    required super.deckId,
    required super.questionText,
    required super.answerText,
    required super.isArchive,
    required bool isLocked,
  }) {
    _isLocked = isLocked;
  }

  factory QuizCardItemWithPremium.fromQuizCard({
    required QuizCardItem quizCardItem,
    required bool isLocked,
  }) {
    return QuizCardItemWithPremium(
      id: quizCardItem.id,
      deckId: quizCardItem.deckId,
      questionText: quizCardItem.questionText,
      answerText: quizCardItem.answerText,
      isArchive: quizCardItem.isArchive,
      isLocked: isLocked,
    );
  }

  @override
  List<Object?> get props => super.props..add(_isLocked);
}
