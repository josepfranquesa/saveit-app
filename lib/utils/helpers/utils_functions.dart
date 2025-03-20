import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

import 'package:flutter/material.dart';

toast(BuildContext context, {String title = "", String type = "info"}) {
  switch (type) {
    case "success":
      return CherryToast.success(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16)),
        animationType: AnimationType.fromRight,
        displayCloseButton: false,
        actionHandler: () {},
      ).show(context);
    case "error":
      return CherryToast.error(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16)),
        animationType: AnimationType.fromRight,
        displayCloseButton: false,
        actionHandler: () {},
      ).show(context);
    case "warning":
      return CherryToast.warning(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16)),
        animationType: AnimationType.fromRight,
        displayCloseButton: false,
        actionHandler: () {},
      ).show(context);
    case "info":
      return CherryToast.info(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16)),
        animationType: AnimationType.fromRight,
        displayCloseButton: false,
        actionHandler: () {},
      ).show(context);
    default:
      return CherryToast.info(
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16)),
        animationType: AnimationType.fromRight,
        displayCloseButton: false,
        actionHandler: () {},
      ).show(context);
  }
}

accidentStatusToString(String status) {
  switch (status) {
    case "reviewd":
      return "Revisado";
    case "created":
      return "Notificado";
    default:
      return "Notificado";
  }
}

benefitTypeToString(String type) {
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

Color insuranceBranchToColor(String? slug) {
  // colors between AppColors.primary and AppColors.fourth
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

Color getContrastColor(Color c) {
  if (c==AppColors.principal || c==AppColors.secondary) {
    return Colors.white;
  } else {
    return AppColors.principal;
  }
}

Color makeColorBrighter(Color color, double amount) {
  assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');

  // Calcular los nuevos componentes RGB
  int r = (color.red + ((255 - color.red) * amount)).round();
  int g = (color.green + ((255 - color.green) * amount)).round();
  int b = (color.blue + ((255 - color.blue) * amount)).round();

  return Color.fromARGB(color.alpha, r, g, b);
}