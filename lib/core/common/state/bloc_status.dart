import 'package:equatable/equatable.dart';

import '../enums/state_status.dart';

class BlocStatus<T> extends Equatable {
  final StateStatus status;
  final String? error;
  final T? data;

  const BlocStatus._(this.status, {this.error, this.data});

  const BlocStatus.initial({T? data}) : this._(StateStatus.initial, data: data);

  const BlocStatus.loading({T? data}) : this._(StateStatus.loading, data: data);

  const BlocStatus.success({required T data})
      : this._(StateStatus.success, data: data);

  const BlocStatus.empty({T? data}) : this._(StateStatus.empty, data: data);

  const BlocStatus.failure({required String error, T? data})
      : this._(StateStatus.failure, error: error, data: data);

  bool get isInitial => status == StateStatus.initial;
  bool get isLoading => status == StateStatus.loading;
  bool get isSuccess => status == StateStatus.success;
  bool get isEmpty => status == StateStatus.empty;
  bool get isFailed => status == StateStatus.failure;

  @override
  List<Object?> get props => [status, error, data];
}
