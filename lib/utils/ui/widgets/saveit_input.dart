import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SaveitInput extends StatelessWidget {
  const SaveitInput(
      {super.key, Key,
        this.boxDecoration,
        this.placeholder = '',
        required this.onChanged,
        this.controller,
        required this.textInputType,
        this.isPassword = false,
        this.validator,
        this.suffixIcon,
        this.initialValue,
        this.multiline = false,
        this.readOnly = false,
        this.focusNode
      });

  final BoxDecoration? boxDecoration;
  final String placeholder;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType textInputType;
  final bool isPassword;
  final Widget? suffixIcon;
  final String? initialValue;
  final bool multiline;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration ?? BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        onChanged: onChanged,
        controller: controller,
        obscureText: isPassword,
        keyboardType: multiline ? TextInputType.multiline : textInputType,
        initialValue: initialValue,
        validator: validator,
        cursorColor: AppColors.principal,
        maxLines: multiline ? 5 : 1,
        readOnly: readOnly,
        focusNode: focusNode,
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            hintText: placeholder,
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.principal,
            ),
            suffixIcon: suffixIcon
        ),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.principal,
        ),
      ),
    );
  }
}