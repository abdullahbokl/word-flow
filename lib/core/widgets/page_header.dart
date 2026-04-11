import 'package:flutter/material.dart';
import 'package:lexitrack/core/constants/app_dimensions.dart';
import 'package:lexitrack/core/widgets/app_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(0, 32, 0, 16),
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
