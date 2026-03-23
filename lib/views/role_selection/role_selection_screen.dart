import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/app_role.dart';
import '../../providers/app_providers.dart';
import '../../viewmodels/role_selection_viewmodel.dart';
import '../../widgets/primary_button.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleSelectionViewModelProvider);
    final startupWarning = ref.watch(startupWarningProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your app flow',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'QueueLess uses a role-first flow. Choose the experience you want to open by default every time the app starts.',
                    ),
                    if (startupWarning != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        startupWarning,
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              title: 'Customer',
              description:
                  'Join a queue, track your token live, ask the AI assistant, and review queue history.',
              icon: Icons.person_outline_rounded,
              button: PrimaryButton(
                label: 'Continue as Customer',
                icon: Icons.arrow_forward_rounded,
                isLoading: state.isLoading,
                onPressed: () => _selectRole(context, ref, AppRole.customer),
              ),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              title: 'Business/Admin',
              description:
                  'Create queues, manage service flow, review AI insights, and monitor analytics.',
              icon: Icons.storefront_rounded,
              button: PrimaryButton(
                label: 'Continue as Admin',
                icon: Icons.arrow_forward_rounded,
                isLoading: state.isLoading,
                onPressed: () => _selectRole(context, ref, AppRole.admin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    AppRole role,
  ) async {
    try {
      await ref.read(roleSelectionViewModelProvider.notifier).selectRole(role);
      if (!context.mounted) {
        return;
      }

      context.go(
        role == AppRole.customer ? AppRoutes.customerHome : AppRoutes.adminHome,
      );
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.button,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 20),
            button,
          ],
        ),
      ),
    );
  }
}
