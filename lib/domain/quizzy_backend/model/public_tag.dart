import 'package:equatable/equatable.dart';

class PublicTag extends Equatable {
  final String slug;
  final String name;

  const PublicTag({
    required this.slug,
    required this.name,
  });

  @override
  List<Object?> get props => [slug, name];
}
