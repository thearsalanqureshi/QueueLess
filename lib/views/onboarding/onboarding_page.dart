import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.highlight,
  });

  final String title;
  final String description;
  final IconData icon;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 640 ? 48 : 20,
            vertical: 16,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      icon,
                      size: 34,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    highlight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(description, style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Live queue tracking, token management, and AI guidance stay in one flow.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
