import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/app_bootstrap.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  final bootstrapData = await bootstrapApplication();

  runApp(
    ProviderScope(
      overrides: [appBootstrapProvider.overrideWithValue(bootstrapData)],
      child: const QueueLessApp(),
    ),
  );
}

// https://github.com/thearsalanqureshi/QueueLess.git