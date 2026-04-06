import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../common/state/bloc_status.dart';
import 'app_error_widget.dart';
import 'app_loader.dart';

class StatusView<T> extends StatelessWidget {
  const StatusView({
    required this.status,
    this.onLoading,
    this.onSuccess,
    this.onEmpty,
    this.onFailure,
    this.onInitial,
    this.animate = true,
    super.key,
  });

  final BlocStatus<T> status;
  final Widget Function()? onInitial;
  final Widget Function()? onLoading;
  final Widget Function(T data)? onSuccess;
  final Widget Function()? onEmpty;
  final Widget Function(String error)? onFailure;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final widget = switch (status.status) {
      var s when s.isInitial => onInitial?.call() ?? const SizedBox.shrink(),
      var s when s.isLoading => onLoading?.call() ?? const AppLoader(),
      var s when s.isSuccess => onSuccess?.call(status.data as T),
      var s when s.isEmpty => onEmpty?.call() ?? const SizedBox.shrink(),
      var s when s.isFailed => onFailure?.call(
            status.error ?? 'An error occurred',
          ) ??
          AppErrorWidget(
            error: status.error ?? 'An error occurred',
          ),
      _ => const SizedBox.shrink(),
    };

    if (animate && !status.isInitial) {
      return widget.animate().fadeIn(duration: 300.ms).moveY(
            begin: 10,
            end: 0,
            curve: Curves.easeOutQuad,
          );
    }
    return widget;
  }
}
