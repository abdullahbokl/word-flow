import 'package:flutter/material.dart';

enum AppTextType { headline, title, body, label, caption }

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    AppTextType? textType,
    this.style,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight,
    this.fontSize,
    this.fontStyle,
    super.key,
  }) : _textType = textType ?? AppTextType.body;

  const AppText.headline(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.bold,
    this.fontSize = 24.0,
    this.fontStyle,
    super.key,
  })  : style = null,
        _textType = AppTextType.headline;

  const AppText.title(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 18.0,
    this.fontStyle,
    super.key,
  })  : style = null,
        _textType = AppTextType.title;

  const AppText.body(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 14.0,
    this.fontStyle,
    super.key,
  })  : style = null,
        _textType = AppTextType.body;

  const AppText.label(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 13.0,
    this.fontStyle,
    super.key,
  })  : style = null,
        _textType = AppTextType.label;

  const AppText.caption(
    this.text, {
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 11.0,
    this.fontStyle,
    super.key,
  })  : style = null,
        _textType = AppTextType.caption;

  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? fontSize;
  final FontStyle? fontStyle;
  final AppTextType _textType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseStyle = style ??
        switch (_textType) {
          AppTextType.headline => theme.textTheme.headlineMedium,
          AppTextType.title => theme.textTheme.titleLarge,
          AppTextType.body => theme.textTheme.bodyMedium,
          AppTextType.label => theme.textTheme.labelMedium,
          AppTextType.caption => theme.textTheme.bodySmall,
        };

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
