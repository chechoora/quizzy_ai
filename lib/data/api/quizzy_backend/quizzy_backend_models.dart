/// Shared request/response DTOs for the quizzy-ai-pro-be.fly.dev backend
/// (Decks, Cards, AiTutor). Plain hand-written classes with manual
/// `fromJson`/`toJson`, matching the convention used by every other API
/// integration under `lib/data/api/`.
library;

/// A bare question/answer pair. The OpenAPI spec defines this shape three
/// times under different names (`CardDto`, `DeckCardDto`, `CardInputDto`) —
/// collapsed here into one class since they're structurally identical.
class CardDto {
  final String question;
  final String answer;

  CardDto({
    required this.question,
    required this.answer,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) => CardDto(
        question: json['question'] as String,
        answer: json['answer'] as String,
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class UsageInfoDto {
  final num totalTokens;
  final num cost;
  final String? usageRecordId;

  UsageInfoDto({
    required this.totalTokens,
    required this.cost,
    this.usageRecordId,
  });

  factory UsageInfoDto.fromJson(Map<String, dynamic> json) => UsageInfoDto(
        totalTokens: json['totalTokens'] as num,
        cost: json['cost'] as num,
        usageRecordId: json['usageRecordId'] as String?,
      );
}

class DeckResponseDto {
  final String id;
  final String userId;
  final String title;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeckResponseDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeckResponseDto.fromJson(Map<String, dynamic> json) =>
      DeckResponseDto(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        isArchived: json['isArchived'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class CardResponseDto {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardResponseDto({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardResponseDto.fromJson(Map<String, dynamic> json) =>
      CardResponseDto(
        id: json['id'] as String,
        deckId: json['deckId'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        isArchived: json['isArchived'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class DeckWithCardsResponseDto {
  final String id;
  final String userId;
  final String title;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CardResponseDto> cards;

  DeckWithCardsResponseDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
  });

  factory DeckWithCardsResponseDto.fromJson(Map<String, dynamic> json) =>
      DeckWithCardsResponseDto(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        isArchived: json['isArchived'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        cards: (json['cards'] as List)
            .map((c) => CardResponseDto.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class CreateDeckDto {
  final String title;
  final List<CardDto>? cards;

  CreateDeckDto({
    required this.title,
    this.cards,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (cards != null) 'cards': cards!.map((c) => c.toJson()).toList(),
      };
}

class UpdateDeckDto {
  final String? title;
  final bool? isArchived;

  UpdateDeckDto({
    this.title,
    this.isArchived,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (isArchived != null) 'isArchived': isArchived,
      };
}

class UpdateCardDto {
  final String? question;
  final String? answer;
  final bool? isArchived;

  UpdateCardDto({
    this.question,
    this.answer,
    this.isArchived,
  });

  Map<String, dynamic> toJson() => {
        if (question != null) 'question': question,
        if (answer != null) 'answer': answer,
        if (isArchived != null) 'isArchived': isArchived,
      };
}

class GenerateDeckDto {
  final String prompt;
  final String? deckTitle;
  final List<CardDto>? currentCards;

  GenerateDeckDto({
    required this.prompt,
    this.deckTitle,
    this.currentCards,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        if (deckTitle != null) 'deckTitle': deckTitle,
        if (currentCards != null)
          'currentCards': currentCards!.map((c) => c.toJson()).toList(),
      };
}

class GenerateDeckResponseDto {
  final List<CardDto> cards;
  final Object? notice;
  final UsageInfoDto usage;

  GenerateDeckResponseDto({
    required this.cards,
    this.notice,
    required this.usage,
  });

  factory GenerateDeckResponseDto.fromJson(Map<String, dynamic> json) =>
      GenerateDeckResponseDto(
        cards: (json['cards'] as List)
            .map((c) => CardDto.fromJson(c as Map<String, dynamic>))
            .toList(),
        notice: json['notice'],
        usage: UsageInfoDto.fromJson(json['usage'] as Map<String, dynamic>),
      );
}

class UserBalanceDto {
  final num weeklyBalanceUsd;
  final num weeklyLimitUsd;
  final num weeklyBalanceReq;
  final num weeklyLimitReq;

  UserBalanceDto({
    required this.weeklyBalanceUsd,
    required this.weeklyLimitUsd,
    required this.weeklyBalanceReq,
    required this.weeklyLimitReq,
  });

  factory UserBalanceDto.fromJson(Map<String, dynamic> json) =>
      UserBalanceDto(
        weeklyBalanceUsd: json['weeklyBalanceUsd'] as num,
        weeklyLimitUsd: json['weeklyLimitUsd'] as num,
        weeklyBalanceReq: json['weeklyBalanceReq'] as num,
        weeklyLimitReq: json['weeklyLimitReq'] as num,
      );
}

class CheckAnswerDto {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final String? context;
  final String? cardId;

  CheckAnswerDto({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    this.context,
    this.cardId,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        if (context != null) 'context': context,
        if (cardId != null) 'cardId': cardId,
      };
}

class AnswerResponseDto {
  final bool isCorrect;
  final String feedback;
  final double confidence;
  final List<String> suggestions;
  final UsageInfoDto usage;

  AnswerResponseDto({
    required this.isCorrect,
    required this.feedback,
    required this.confidence,
    required this.suggestions,
    required this.usage,
  });

  factory AnswerResponseDto.fromJson(Map<String, dynamic> json) =>
      AnswerResponseDto(
        isCorrect: json['isCorrect'] as bool,
        feedback: json['feedback'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        suggestions: ((json['suggestions'] as List?) ?? const [])
            .map((s) => s as String)
            .toList(),
        usage: UsageInfoDto.fromJson(json['usage'] as Map<String, dynamic>),
      );
}

class PublicTagDto {
  final String slug;
  final String name;

  PublicTagDto({
    required this.slug,
    required this.name,
  });

  factory PublicTagDto.fromJson(Map<String, dynamic> json) => PublicTagDto(
        slug: json['slug'] as String,
        name: json['name'] as String,
      );
}

class PublicCategoryDto {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final num deckCount;

  PublicCategoryDto({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.deckCount,
  });

  factory PublicCategoryDto.fromJson(Map<String, dynamic> json) =>
      PublicCategoryDto(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        deckCount: json['deckCount'] as num,
      );
}

class PublicDeckSummaryDto {
  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final List<PublicTagDto> tags;
  final num cardCount;

  PublicDeckSummaryDto({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.tags,
    required this.cardCount,
  });

  factory PublicDeckSummaryDto.fromJson(Map<String, dynamic> json) =>
      PublicDeckSummaryDto(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        tags: (json['tags'] as List)
            .map((t) => PublicTagDto.fromJson(t as Map<String, dynamic>))
            .toList(),
        cardCount: json['cardCount'] as num,
      );
}

class PublicDeckPageDto {
  final List<PublicDeckSummaryDto> items;
  final String? nextCursor;
  final bool hasMore;

  PublicDeckPageDto({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  factory PublicDeckPageDto.fromJson(Map<String, dynamic> json) =>
      PublicDeckPageDto(
        items: (json['items'] as List)
            .map((d) =>
                PublicDeckSummaryDto.fromJson(d as Map<String, dynamic>))
            .toList(),
        nextCursor: json['nextCursor'] as String?,
        hasMore: json['hasMore'] as bool,
      );
}

class PublicCardDto {
  final String id;
  final String question;
  final String answer;
  final num position;

  PublicCardDto({
    required this.id,
    required this.question,
    required this.answer,
    required this.position,
  });

  factory PublicCardDto.fromJson(Map<String, dynamic> json) => PublicCardDto(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        position: json['position'] as num,
      );
}

class PublicDeckDetailDto {
  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final List<PublicTagDto> tags;
  final num cardCount;
  final List<PublicCardDto> cards;

  PublicDeckDetailDto({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.tags,
    required this.cardCount,
    required this.cards,
  });

  factory PublicDeckDetailDto.fromJson(Map<String, dynamic> json) =>
      PublicDeckDetailDto(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        tags: (json['tags'] as List)
            .map((t) => PublicTagDto.fromJson(t as Map<String, dynamic>))
            .toList(),
        cardCount: json['cardCount'] as num,
        cards: (json['cards'] as List)
            .map((c) => PublicCardDto.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
