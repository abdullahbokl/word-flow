import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:lexitrack/core/common/enums/state_status.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';
import 'package:lexitrack/core/widgets/app_error_widget.dart';
import 'package:lexitrack/core/widgets/app_loader.dart';

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
      StateStatus.initial => onInitial?.call() ?? const SizedBox.shrink(),
      StateStatus.loading => onLoading?.call() ?? const AppLoader(),
      StateStatus.success => onSuccess?.call(status.data as T),
      StateStatus.empty => onEmpty?.call() ?? const SizedBox.shrink(),
      StateStatus.failure => onFailure?.call(
            status.error ?? 'An error occurred',
          ) ??
          AppErrorWidget(
            error: status.error ?? 'An error occurred',
          ),
    };

    if (animate && !status.isInitial) {
      return widget!.animate().fadeIn(duration: 300.ms).moveY(
            begin: 10,
            end: 0,
            curve: Curves.easeOutQuad,
          );
    }
    return widget!;
  }
}
