import 'package:flutter/material.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/gen/assets.gen.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.label,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.maxLines = 1,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextInputType textInputType;
  final int maxLines;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType,
      maxLines: widget.maxLines,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: widget.isPassword && _isPasswordVisible,
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      onChanged: widget.onChanged,
      style: textTheme.titleSmall,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: textTheme.titleSmall.copyWith(
          color: colors.grey[200],
        ),
        errorStyle: textTheme.labelSmall.copyWith(color: Colors.red),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: _isPasswordVisible
                    ? Assets.icons.eyeSlash.svg(
                      color: colors.grey[200],
                    )
                    : Assets.icons.eye.svg(
                      color: colors.grey[200],
                    ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 20,
          maxHeight: 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colors.neutral[400]!,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colors.primary[600]!,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
