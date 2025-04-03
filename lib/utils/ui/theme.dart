import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SaveItTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.appBackground,
      fontFamily: 'Poppins',
      textTheme: _textTheme,
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      titleLarge: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w700,
        color: AppColors.principal,
      ),
      titleMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: AppColors.principal,
      ),
      titleSmall: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: AppColors.principal,
      ),
      labelLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: AppColors.principal,
      ),
      labelMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.principal,
      ),
      bodyLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: AppColors.principal,
      ),
      bodyMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: AppColors.principal,
      ),
    );
  }
}