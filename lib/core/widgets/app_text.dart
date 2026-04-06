import 'package:flutter/material.dart';

enum _TextStyle { headline, title, body, label, caption }

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    _TextStyle? textType,
    this.style,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.fontWeight,
    this.fontSize,
    this.fontStyle,
    super.key,
  })  : _textType = textType ?? _TextStyle.body,
        style = null;

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
        _textType = _TextStyle.headline;

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
        _textType = _TextStyle.title;

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
        _textType = _TextStyle.body;

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
        _textType = _TextStyle.label;

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
        _textType = _TextStyle.caption;

  final String text;
  final TextStyle? style;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? fontSize;
  final FontStyle? fontStyle;
  final _TextStyle _textType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseStyle = style ??
        switch (_textType) {
          _TextStyle.headline => theme.textTheme.headlineMedium,
          _TextStyle.title => theme.textTheme.titleLarge,
          _TextStyle.body => theme.textTheme.bodyMedium,
          _TextStyle.label => theme.textTheme.labelMedium,
          _TextStyle.caption => theme.textTheme.bodySmall,
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
