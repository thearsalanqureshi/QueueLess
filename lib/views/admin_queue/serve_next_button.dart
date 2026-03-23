import 'package:flutter/material.dart';

import '../../widgets/primary_button.dart';

class ServeNextButton extends StatelessWidget {
  const ServeNextButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Serve Next',
      icon: Icons.skip_next_rounded,
      onPressed: onPressed,
      isLoading: isLoading,
      isExpanded: false,
    );
  }
}
