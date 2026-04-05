import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../enums/state_status.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/app_loader.dart';

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

  Widget when({
    required Widget Function(T data) success,
    Widget Function()? loading,
    Widget Function(String error)? failure,
    Widget Function()? empty,
    Widget Function()? initial,
    bool animate = true,
  }) {
    final widget = switch (status) {
      StateStatus.initial => initial?.call() ?? const SizedBox.shrink(),
      StateStatus.loading => loading?.call() ?? const AppLoader(),
      StateStatus.success => success(data as T),
      StateStatus.empty => empty?.call() ?? const SizedBox.shrink(),
      StateStatus.failure =>
        failure?.call(error ?? 'An error occurred') ??
            AppErrorWidget(error: error ?? 'An error occurred'),
    };

    if (animate && !isInitial) {
      return widget.animate().fadeIn(duration: 300.ms).moveY(
            begin: 10,
            end: 0,
            curve: Curves.easeOutQuad,
          );
    }
    return widget;
  }

  @override
  List<Object?> get props => [status, error, data];
}
