import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:flutter/material.dart';

Widget insuranceBranchToIcon(String slug, {double size = 30, Color color = AppColors.principal}) {
  switch(slug) {
    case 'all':
      return Icon(Icons.shield_outlined, color: color, size: size);
    case 'decesos':
      return Icon(Icons.local_florist_outlined, color: color, size: size);
    case 'defensa-juridica':
      return Icon(Icons.balance_outlined, color: color, size: size);
    case 'multirriesgo-hogar':
      return Icon(Icons.house_outlined, color: color, size: size);
    case 'accidentes':
      return Icon(Icons.personal_injury_outlined, color: color, size: size);
    case 'autos':
      return Icon(Icons.directions_car_outlined, color: color, size: size);
    case 'credito':
      return Icon(Icons.request_quote_outlined, color: color, size: size);
    case 'salud':
      return Icon(Icons.medical_services_outlined, color: color, size: size);
    case 'vida':
      return Icon(Icons.favorite_outline, color: color, size: size);
    case 'multirriesgo':
      return Icon(Icons.factory_outlined, color: color, size: size);
    case 'rc':
      return Icon(Icons.work_outline, color: color, size: size);
    case 'travel':
      return Icon(Icons.flight_takeoff_outlined, color: color, size: size);
    case 'pet':
      return Icon(Icons.pets_outlined, color: color, size: size);
    case 'otros':
      return Icon(Icons.grid_view_outlined, color: color, size: size);
    default:
      return Icon(Icons.abc_outlined, color: color, size: size);
  }

}