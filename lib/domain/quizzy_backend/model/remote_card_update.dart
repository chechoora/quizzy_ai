import 'package:equatable/equatable.dart';

/// A partial edit to an already-synced remote card, keyed by its backend id.
class RemoteCardUpdate extends Equatable {
  final String remoteId;
  final String? question;
  final String? answer;
  final bool? isArchived;

  const RemoteCardUpdate({
    required this.remoteId,
    this.question,
    this.answer,
    this.isArchived,
  });

  @override
  List<Object?> get props => [remoteId, question, answer, isArchived];
}
