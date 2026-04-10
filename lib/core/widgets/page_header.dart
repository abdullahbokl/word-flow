import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import 'app_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding, 32, AppDimensions.pagePadding, 16),
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
