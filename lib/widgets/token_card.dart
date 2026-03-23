import 'package:flutter/material.dart';

class TokenCard extends StatelessWidget {
  const TokenCard({
    super.key,
    required this.queueName,
    required this.tokenNumber,
    required this.caption,
  });

  final String queueName;
  final int tokenNumber;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(queueName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 18),
            Text('T$tokenNumber', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(caption),
          ],
        ),
      ),
    );
  }
}
