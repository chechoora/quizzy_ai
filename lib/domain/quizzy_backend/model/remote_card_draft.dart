import 'package:equatable/equatable.dart';

/// A question/answer pair that hasn't been persisted yet (e.g. AI-generated
/// deck previews before the user saves them).
class RemoteCardDraft extends Equatable {
  final String question;
  final String answer;

  const RemoteCardDraft({
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [question, answer];
}
