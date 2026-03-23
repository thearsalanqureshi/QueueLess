import 'package:flutter/material.dart';

class QueueIdInputWidget extends StatelessWidget {
  const QueueIdInputWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      decoration: const InputDecoration(
        labelText: 'Queue ID',
        hintText: 'Enter the six-character queue code',
        prefixIcon: Icon(Icons.pin_outlined),
      ),
    );
  }
}
