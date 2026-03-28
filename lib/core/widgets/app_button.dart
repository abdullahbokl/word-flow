import 'package:flutter/material.dart';
import 'app_loader.dart';

enum AppButtonVariant { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? AppLoader(
            size: 20,
            color: _loadingColor(context),
          )
        : Text(label);

    final button = switch (variant) {
      AppButtonVariant.primary =>
        icon == null
            ? FilledButton(
                onPressed: isLoading ? null : onPressed,
                child: content,
              )
            : FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: Icon(icon),
                label: content,
              ),
      AppButtonVariant.secondary =>
        icon == null
            ? FilledButton.tonal(
                onPressed: isLoading ? null : onPressed,
                child: content,
              )
            : FilledButton.tonalIcon(
                onPressed: isLoading ? null : onPressed,
                icon: Icon(icon),
                label: content,
              ),
      AppButtonVariant.outline =>
        icon == null
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                child: content,
              )
            : OutlinedButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: Icon(icon),
                label: content,
              ),
    };

    return SizedBox(width: double.infinity, child: button);
  }

  Color _loadingColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return variant == AppButtonVariant.primary
        ? scheme.onPrimary
        : scheme.primary;
  }
}
