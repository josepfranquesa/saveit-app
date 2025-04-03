import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:flutter/material.dart';

class FilledSimpleButton extends StatelessWidget {
  const FilledSimpleButton({
    super.key,
    required this.text,
    required this.onPressedFunction,
    this.primary = true
  });

  final String text;
  final void Function(BuildContext context) onPressedFunction;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          //minimumSize: const Size.fromHeight(AppLayout.minCardButtonHeight),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.white,
      ),
      onPressed: () {
        onPressedFunction(context);
      },
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.principal,
          fontWeight: FontWeight.w800,
        ),
      ),

    );
  }
}