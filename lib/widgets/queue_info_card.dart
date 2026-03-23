import 'package:flutter/material.dart';

class QueueInfoCard extends StatelessWidget {
  const QueueInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[Icon(icon), const SizedBox(height: 10)],
            Text(value, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
