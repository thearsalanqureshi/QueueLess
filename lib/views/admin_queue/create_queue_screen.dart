import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../viewmodels/admin_queue_viewmodel.dart';
import '../../widgets/primary_button.dart';
import 'queue_qr_widget.dart';

class CreateQueueScreen extends ConsumerStatefulWidget {
  const CreateQueueScreen({super.key});

  @override
  ConsumerState<CreateQueueScreen> createState() => _CreateQueueScreenState();
}

class _CreateQueueScreenState extends ConsumerState<CreateQueueScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _avgServiceTimeController = TextEditingController(
    text: '5',
  );

  @override
  void dispose() {
    _businessNameController.dispose();
    _avgServiceTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createQueueViewModelProvider);
    final createdQueue = state.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Queue')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            if (createdQueue == null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create an admin queue',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter the business name and average service time. QueueLess will generate a queue ID and QR code for customers.',
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          hintText: 'Happy Lab',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _avgServiceTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Average Service Time (minutes)',
                          hintText: '5',
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Create Queue',
                        icon: Icons.add_business_rounded,
                        isLoading: state.isLoading,
                        onPressed: () => _submit(context),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Queue created successfully',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${createdQueue.name} is ready for customers to join.',
                      ),
                      const SizedBox(height: 18),
                      QueueQrWidget(queueId: createdQueue.queueId),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Open Admin Dashboard',
                        icon: Icons.dashboard_customize_rounded,
                        onPressed: () {
                          context.go(
                            AppRoutes.adminDashboardLocation(
                              queueId: createdQueue.queueId,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(createQueueViewModelProvider.notifier)
                                .reset();
                          },
                          child: const Text('Create Another Queue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final businessName = _businessNameController.text.trim();
    final avgServiceTime = int.tryParse(_avgServiceTimeController.text.trim());

    if (businessName.isEmpty) {
      showAppSnackBar(context, 'Enter a business name.', isError: true);
      return;
    }
    if (avgServiceTime == null || avgServiceTime <= 0) {
      showAppSnackBar(
        context,
        'Average service time must be a valid number.',
        isError: true,
      );
      return;
    }

    try {
      await ref
          .read(createQueueViewModelProvider.notifier)
          .createQueue(
            businessName: businessName,
            avgServiceTime: avgServiceTime,
          );
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }
}
