import 'package:flutter/material.dart';

class QueueProgressWidget extends StatelessWidget {
  const QueueProgressWidget({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Queue Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress.clamp(0, 1).toDouble()),
            const SizedBox(height: 10),
            const Text(
              'Your token moves closer as the current token advances in Firestore.',
            ),
          ],
        ),
      ),
    );
  }
}
