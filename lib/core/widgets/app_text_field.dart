import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final void Function(PointerDownEvent)? onTapOutside;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textCapitalization: textCapitalization,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
        onTapOutside?.call(event);
      },
    );
  }
}
