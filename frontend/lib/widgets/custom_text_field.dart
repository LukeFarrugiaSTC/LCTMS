import 'package:flutter/material.dart';

//Enum representing the types of text fields supported
enum TextFieldType {
  textRequired,
  textOptional,
  mobile,
  email,
  password,
  confirmPassword,
}

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.textFieldType,
    this.obscureText = false,
    this.suffixIcon,
    this.confirmPasswordController,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength = 255,
    this.counterText = '',
    this.autocorrect = false,
    this.enabled = true,
    this.textStyle,
    this.isEditing = true,
  });

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  final String labelText;
  final TextEditingController controller;
  final TextFieldType textFieldType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? confirmPasswordController;
  final TextCapitalization textCapitalization;
  final int maxLength;
  final String counterText;
  final bool autocorrect;
  final bool enabled;
  final TextStyle? textStyle;
  final bool isEditing;

  //helper method that autoselects keyboard type according to textFiledType

  static TextInputType getKeyboardType(TextFieldType type) {
    switch (type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.password:
      case TextFieldType.confirmPassword:
        return TextInputType.visiblePassword;
      case TextFieldType.mobile:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  // Validates user input depending on textFieldType
  String? _validateUserInput(String? value) {
    //general validation for all TextFieldTypes
    if (value == null ||
        (textFieldType != TextFieldType.textOptional && value.trim().isEmpty)) {
      return '$labelText is required';
    }

    //validation for different types of text input fields
    switch (textFieldType) {
      case TextFieldType.email:
        return _emailRegExp.hasMatch(value) ? null : 'Invalid email format';
      case TextFieldType.password:
        return value.length >= 8 ? null : 'Invalid Password';
      case TextFieldType.confirmPassword:
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (value != confirmPasswordController?.text) {
          return 'Passwords do not match';
        }
        return null;
      case TextFieldType.mobile:
      case TextFieldType
          .textRequired: //should never be null or empty due to general validation
        return null;
      case TextFieldType.textOptional:
        return null; //should never be null but can be empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text(labelText),
        counterText: counterText,
        suffixIcon: suffixIcon,
      ),
      keyboardType: getKeyboardType(textFieldType),
      obscureText: //Makes sure that when the field is a password, it is always obscured
          textFieldType == TextFieldType.password ||
          textFieldType == TextFieldType.confirmPassword ||
          obscureText,
      maxLength: maxLength,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      validator: _validateUserInput,
      enabled: enabled && isEditing,
      style:
          textStyle ??
          TextStyle(
            color:
                enabled && isEditing
                    ? Colors.black
                    : Colors.grey, // Change text color when disabled
          ),
    );
  }
}
