import 'package:equatable/equatable.dart';

class DeckItem extends Equatable {
  final int id;
  final int? uid;
  final String title;
  final bool isArchive;

  const DeckItem({
    required this.id,
    required this.title,
    required this.isArchive,
    this.uid,
  });

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        isArchive,
      ];
}
