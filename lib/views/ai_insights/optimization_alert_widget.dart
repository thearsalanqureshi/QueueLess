import 'package:flutter/material.dart';

class OptimizationAlertWidget extends StatelessWidget {
  const OptimizationAlertWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_fix_high_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
