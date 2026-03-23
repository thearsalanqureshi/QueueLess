import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QueueQrWidget extends StatelessWidget {
  const QueueQrWidget({super.key, required this.queueId});

  final String queueId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Queue QR', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Center(child: QrImageView(data: queueId, size: 180)),
            const SizedBox(height: 12),
            Center(
              child: SelectableText(
                queueId,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
