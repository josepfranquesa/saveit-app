import 'package:flutter/material.dart';

class TextFieldGeneral extends StatelessWidget {
  final String labelText;
  final Icon icon;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool hasError; // Indica si el campo tiene error
  final String? errorMessage; // Mensaje de error opcional

  const TextFieldGeneral({
    required this.labelText,
    required this.icon,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hasError = false,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey, // Borde rojo si hay error
              width: 2,
            ),
          ),
          child: TextField(
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: icon,
              labelText: labelText,
              labelStyle: const TextStyle(
                color: Colors.black, // Mantiene el label en negro
              ),
              border: InputBorder.none, // Elimina el borde por defecto del InputDecoration
            ),
            onChanged: onChanged,
            style: TextStyle(
              color: hasError ? Colors.red : Colors.black, // Solo cambia el color del texto de entrada
            ),
          ),
        ),
        if (hasError && errorMessage != null) // Muestra el mensaje de error debajo del campo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}
