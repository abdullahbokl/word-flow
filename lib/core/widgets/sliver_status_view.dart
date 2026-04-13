import 'package:flutter/material.dart';
import 'package:wordflow/core/common/enums/state_status.dart';
import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/core/widgets/app_error_widget.dart';
import 'package:wordflow/core/widgets/app_loader.dart';

/// A version of [StatusView] that always returns Slivers.
/// Useful for [CustomScrollView] bodies.
class SliverStatusView<T> extends StatelessWidget {
  const SliverStatusView({
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
      StateStatus.initial => onInitial?.call() ??
          const SliverFillRemaining(child: SizedBox.shrink()),
      StateStatus.loading =>
        onLoading?.call() ?? const SliverFillRemaining(child: AppLoader()),
      StateStatus.success => onSuccess?.call(status.data as T) ??
          const SliverToBoxAdapter(child: SizedBox.shrink()),
      StateStatus.empty =>
        onEmpty?.call() ?? const SliverFillRemaining(child: SizedBox.shrink()),
      StateStatus.failure =>
        onFailure?.call(status.error ?? 'An error occurred') ??
            SliverFillRemaining(
              child: AppErrorWidget(error: status.error ?? 'An error occurred'),
            ),
    };

    return widget;
  }
}
