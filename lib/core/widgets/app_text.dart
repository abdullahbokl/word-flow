import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    this.style,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight,
    this.fontSize,
    this.fontStyle,
    super.key,
  });

  const AppText.headline(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.bold,
    this.fontSize = 24,
    this.fontStyle,
    super.key,
  }) : style = null;

  const AppText.title(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 18,
    this.fontStyle,
    super.key,
  }) : style = null;

  const AppText.body(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 14,
    this.fontStyle,
    super.key,
  }) : style = null;

  const AppText.label(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 13,
    this.fontStyle,
    super.key,
  }) : style = null;

  const AppText.caption(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 11,
    this.fontStyle,
    super.key,
  }) : style = null;

  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? fontSize;
  final FontStyle? fontStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle? baseStyle = style;
    if (baseStyle == null) {
      if (fontSize == 24) {
        baseStyle = theme.textTheme.headlineMedium;
      } else if (fontSize == 18) {
        baseStyle = theme.textTheme.titleLarge;
      } else if (fontSize == 11) {
        baseStyle = theme.textTheme.bodySmall;
      } else if (fontSize == 13) {
        baseStyle = theme.textTheme.labelMedium;
      } else {
        baseStyle = theme.textTheme.bodyMedium;
      }
    }

    return Text(
      text,
      style: baseStyle?.copyWith(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: fontStyle,
      ),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
