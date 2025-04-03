import 'package:flutter/material.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';

class AppUtils {
  /// Muestra un toast personalizado usando SnackBar.
  static void toast(BuildContext context, {String title = "", String type = "info"}) {
    Color backgroundColor;
    IconData iconData;

    // Configurar el color e ícono según el tipo de mensaje
    switch (type) {
      case "success":
        backgroundColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case "error":
        backgroundColor = Colors.red;
        iconData = Icons.error;
        break;
      case "warning":
        backgroundColor = Colors.orange;
        iconData = Icons.warning;
        break;
      case "info":
      default:
        backgroundColor = Colors.blue;
        iconData = Icons.info;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(iconData, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Convierte el estado de un accidente a un String descriptivo.
  static String accidentStatusToString(String status) {
    switch (status) {
      case "reviewd":
        return "Revisado";
      case "created":
        return "Notificado";
      default:
        return "Notificado";
    }
  }

  /// Convierte el tipo de beneficio a un String descriptivo.
  static String benefitTypeToString(String type) {
    switch (type) {
      case "discount":
        return "Descuento";
      case "cashback":
        return "Regalo";
      case "free":
        return "Gratis";
      default:
        return "Otro";
    }
  }

  /// Devuelve un color asociado a una rama de seguros, basado en un slug.
  static Color insuranceBranchToColor(String? slug) {
    switch (slug) {
      case 'all':
        return AppColors.principal;
      case 'decesos':
        return AppColors.secondary;
      case 'defensa-juridica':
        return AppColors.tertiary;
      case 'autos':
        return AppColors.secondary;
      case 'multirriesgo':
        return AppColors.secondary;
      case 'otros':
        return AppColors.secondary;
      default:
        return AppColors.principal;
    }
  }

  /// Devuelve un color de contraste para asegurar legibilidad.
  static Color getContrastColor(Color c) {
    if (c == AppColors.principal || c == AppColors.secondary) {
      return Colors.white;
    } else {
      return AppColors.principal;
    }
  }

  /// Devuelve una versión más brillante del color dado, incrementando sus componentes RGB.
  static Color makeColorBrighter(Color color, double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');

    int r = (color.red + ((255 - color.red) * amount)).round();
    int g = (color.green + ((255 - color.green) * amount)).round();
    int b = (color.blue + ((255 - color.blue) * amount)).round();

    return Color.fromARGB(color.alpha, r, g, b);
  }
}
