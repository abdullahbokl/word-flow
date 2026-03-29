import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {

  const UserEntity({
    required this.id,
    required this.email,
  });
  final String id;
  final String email;

  @override
  List<Object?> get props => [id, email];
}
