import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final bool? filled;
  final bool? readOnly;
  final bool? isDense;
  final bool isGreyBorder;
  final int? maxLength;
  final String? counterText;
  final String? prefixText;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const DynamicTextfield({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.keyboardType,
    this.hintStyle,
    this.style,
    this.labelStyle,
    this.filled,
    this.readOnly,
    this.isDense,
    required this.isGreyBorder,
    this.maxLength,
    this.counterText,
    this.prefixText,
    this.contentPadding,
    this.inputFormatters,
    this.autovalidateMode,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderSide: BorderSide(
        color: isGreyBorder ? Colors.grey : Colors.transparent,
      ),
      borderRadius: BorderRadius.circular(10),
    );

    return TextFormField(
      controller: controller,
      style: style,
      maxLength: maxLength,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly ?? false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        contentPadding: contentPadding,
        filled: filled ?? false,
        isDense: isDense ?? false,
        labelText: labelText,
        labelStyle: labelStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: hintStyle,
        counterText: counterText,
        prefixText: prefixText,
        border: borderStyle,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle,
        errorBorder: borderStyle,
      ),
    );
  }
}
