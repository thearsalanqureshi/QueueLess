import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../viewmodels/join_queue_viewmodel.dart';
import '../../widgets/primary_button.dart';
import 'queue_id_input_widget.dart';

class JoinQueueScreen extends ConsumerStatefulWidget {
  const JoinQueueScreen({super.key});

  @override
  ConsumerState<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends ConsumerState<JoinQueueScreen> {
  final TextEditingController _queueIdController = TextEditingController();

  @override
  void dispose() {
    _queueIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(joinQueueViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Join Queue')),
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
                      'Join with Queue ID or QR code',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter the business queue code or scan the shared QR. You will receive a live token and queue status instantly.',
                    ),
                    const SizedBox(height: 24),
                    QueueIdInputWidget(controller: _queueIdController),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _scanQrCode,
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scan QR Code'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Join Queue',
                      icon: Icons.login_rounded,
                      isLoading: asyncState.isLoading,
                      onPressed: () => _submit(context),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Live status will show the current token, your token, people ahead, estimated wait, and AI queue assistance.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final queueId = _queueIdController.text.trim();
    if (queueId.isEmpty) {
      showAppSnackBar(context, 'Enter a queue id first.', isError: true);
      return;
    }

    try {
      final token = await ref
          .read(joinQueueViewModelProvider.notifier)
          .joinQueue(queueId);
      if (!context.mounted) {
        return;
      }
      context.push(
        AppRoutes.customerQueueStatusLocation(
          queueId: token.queueId,
          tokenId: token.tokenId,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(context, friendlyError(error), isError: true);
    }
  }

  Future<void> _scanQrCode() async {
    var hasResolved = false;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  if (hasResolved) {
                    return;
                  }
                  final code = capture.barcodes.isNotEmpty
                      ? capture.barcodes.first.rawValue
                      : null;
                  if (code == null || code.isEmpty) {
                    return;
                  }
                  hasResolved = true;
                  Navigator.of(context).pop(code);
                },
              ),
              Positioned(
                top: 18,
                right: 18,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      _queueIdController.text = result.toUpperCase();
    }
  }
}
