import 'package:equatable/equatable.dart';

class CustomTag extends Equatable {
  const CustomTag({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final int id;
  final String name;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, createdAt];
}
