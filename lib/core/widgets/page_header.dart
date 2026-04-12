import 'package:flutter/material.dart';
import 'package:lexitrack/core/widgets/app_text.dart';
import 'package:lexitrack/core/constants/app_dimensions.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.pagePadding,
      vertical: AppDimensions.space24,
    ),
    this.showBackButton = false,
    super.key,
  });

  final String title;
  final EdgeInsets padding;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(child: AppText.headline(title)),
        ],
      ),
    );
  }
}
