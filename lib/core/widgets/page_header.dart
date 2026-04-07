import 'package:flutter/material.dart';
import 'app_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(24, 32, 24, 16),
    super.key,
  });

  final String title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppText.headline(title),
    );
  }
}
