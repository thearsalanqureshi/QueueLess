import 'package:flutter/material.dart';

import '../../models/queue_insight_model.dart';
import '../../widgets/queue_info_card.dart';

class InsightsPanelWidget extends StatelessWidget {
  const InsightsPanelWidget({super.key, required this.insights});

  final QueueInsightModel insights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Business Insights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(insights.headline),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 620;
                final cards = [
                  QueueInfoCard(
                    label: 'Served Today',
                    value: insights.totalServedToday.toString(),
                    icon: Icons.task_alt_rounded,
                  ),
                  QueueInfoCard(
                    label: 'Avg Service',
                    value:
                        '${insights.averageServiceMinutes.toStringAsFixed(1)} min',
                    icon: Icons.timelapse_rounded,
                  ),
                  QueueInfoCard(
                    label: 'Peak Hour',
                    value: insights.peakHour,
                    icon: Icons.query_stats_rounded,
                  ),
                ];

                if (!isWide) {
                  return Column(
                    children: [
                      for (final card in cards) ...[
                        card,
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      Expanded(child: cards[index]),
                      if (index < cards.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Text(insights.suggestion),
          ],
        ),
      ),
    );
  }
}
