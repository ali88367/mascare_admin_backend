import 'package:flutter/material.dart';

import '../colors.dart';

class InputField extends StatelessWidget {
  final FocusNode? focusNode;
  final int maxlines;
  final String? label;
  final EdgeInsetsGeometry? contentPadding;
  final String hint;
  final TextEditingController? controller;
  final FormFieldValidator<String?>? validator;
  final TextStyle hintStyle;
  final TextStyle inputTextStyle;
  final TextInputType keyboard;
  final Color? cursorColor;
  final bool readOnly;
  final ValueChanged<String?>? onChanged;

  const InputField({
    super.key,
    this.label,
    required this.hint,
    required this.keyboard,
    this.hintStyle = const TextStyle(
      color: Color(0xff828282),
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    this.inputTextStyle = const TextStyle(color: Colors.black),
    this.controller,
    this.cursorColor,
    this.validator,
    this.readOnly = false,
    this.contentPadding,
    this.maxlines = 1,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      focusNode: focusNode,
      maxLines: maxlines,
      readOnly: readOnly,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      textInputAction: TextInputAction.next,
      style: inputTextStyle,
      cursorColor: cursorColor,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: hintStyle,
        labelText: label,
        labelStyle: const TextStyle(color: blackColor),
        contentPadding: contentPadding,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: blackColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: blackColor),

        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: blackColor),

        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: blackColor),

          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
