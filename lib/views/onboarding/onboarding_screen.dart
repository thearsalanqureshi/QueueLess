import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../widgets/primary_button.dart';
import 'onboarding_page.dart';
import 'onboarding_widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  final _pages = const [
    (
      title: 'Avoid long queues',
      description:
          'Join a business queue remotely, keep your time, and only return when your turn is close.',
      icon: Icons.hourglass_bottom_rounded,
      highlight: 'Customer flow',
    ),
    (
      title: 'Get digital tokens',
      description:
          'Use a queue ID or scan a QR code to receive a digital token with live progress updates.',
      icon: Icons.qr_code_scanner_rounded,
      highlight: 'Digital entry',
    ),
    (
      title: 'Track your turn live',
      description:
          'See the current token, your token, people ahead, and AI wait estimates in real time.',
      icon: Icons.insights_rounded,
      highlight: 'Live tracking',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  ref.read(onboardingViewModelProvider.notifier).setPage(index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    title: page.title,
                    description: page.description,
                    icon: page.icon,
                    highlight: page.highlight,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  OnboardingDots(
                    currentIndex: currentIndex,
                    total: _pages.length,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: currentIndex == AppConstants.onboardingPages - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () async {
                      if (currentIndex == AppConstants.onboardingPages - 1) {
                        await ref
                            .read(onboardingViewModelProvider.notifier)
                            .complete();
                        if (context.mounted) {
                          context.go(AppRoutes.roleSelection);
                        }
                        return;
                      }

                      ref.read(onboardingViewModelProvider.notifier).nextPage();
                      await _pageController.nextPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
