import 'package:flutter/material.dart';

class SaveitSelector extends StatelessWidget {
  const SaveitSelector(
      {super.key,
        this.boxDecoration,
        required this.onChanged,
        required this.items,
        required this.value
      });

  final BoxDecoration? boxDecoration;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        decoration: boxDecoration ?? BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButton(
          value: value,
          items: items,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black,
          ),
          underline: Container(),
        )
    );
  }
}