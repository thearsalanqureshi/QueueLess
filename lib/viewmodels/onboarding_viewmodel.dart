import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../providers/app_providers.dart';

final onboardingViewModelProvider = NotifierProvider<OnboardingViewModel, int>(
  OnboardingViewModel.new,
);

class OnboardingViewModel extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int index) {
    state = index;
  }

  void nextPage() {
    final nextIndex = state + 1;
    state = nextIndex >= AppConstants.onboardingPages
        ? AppConstants.onboardingPages - 1
        : nextIndex;
  }

  Future<void> complete() {
    return ref.read(hiveServiceProvider).setOnboardingCompleted(true);
  }
}
