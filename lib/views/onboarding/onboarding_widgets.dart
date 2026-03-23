import 'package:flutter/material.dart';

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: index == currentIndex
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
