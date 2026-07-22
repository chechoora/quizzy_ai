import 'package:equatable/equatable.dart';

class PublicCard extends Equatable {
  final String id;
  final String question;
  final String answer;
  final num position;

  const PublicCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.position,
  });

  @override
  List<Object?> get props => [id, question, answer, position];
}
