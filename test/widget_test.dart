import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:queueless/models/active_queue_session.dart';
import 'package:queueless/models/queue_history_entry.dart';
import 'package:queueless/viewmodels/admin_home_viewmodel.dart';
import 'package:queueless/viewmodels/customer_home_viewmodel.dart';
import 'package:queueless/views/admin/admin_home_screen.dart';
import 'package:queueless/views/customer/customer_home_screen.dart';

class _FakeCustomerHomeViewModel extends CustomerHomeViewModel {
  _FakeCustomerHomeViewModel(this._state);

  final CustomerHomeState _state;

  @override
  Future<CustomerHomeState> build() async {
    return _state;
  }
}

class _FakeAdminHomeViewModel extends AdminHomeViewModel {
  _FakeAdminHomeViewModel(this._state);

  final AdminHomeState _state;

  @override
  Future<AdminHomeState> build() async {
    return _state;
  }
}

void main() {
  testWidgets('Customer home shows join queue and history actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerHomeViewModelProvider.overrideWith(
            () => _FakeCustomerHomeViewModel(
              const CustomerHomeState(
                recentHistory: [],
                activeSession: null,
                startupWarning: null,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: CustomerHomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Join Queue'), findsWidgets);
    expect(find.text('Open History'), findsOneWidget);
  });

  testWidgets('Customer home shows resume card when active session exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerHomeViewModelProvider.overrideWith(
            () => _FakeCustomerHomeViewModel(
              const CustomerHomeState(
                recentHistory: [],
                activeSession: ActiveQueueSession(
                  queueId: 'QUEUE1',
                  queueName: 'Demo Queue',
                  tokenId: 'token-1',
                  tokenNumber: 14,
                ),
                startupWarning: null,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: CustomerHomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Resume Active Queue'), findsOneWidget);
    expect(find.text('Open Queue Status'), findsOneWidget);
  });

  testWidgets('Admin home shows create queue and analytics actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminHomeViewModelProvider.overrideWith(
            () => _FakeAdminHomeViewModel(
              AdminHomeState(
                recentHistory: [
                  QueueHistoryEntry(
                    id: 'queue_QUEUE1',
                    queueId: 'QUEUE1',
                    queueName: 'Main Branch',
                    createdAt: DateTime(2026, 3, 23),
                    role: QueueHistoryEntry.adminRole,
                    statusLabel: 'Created queue',
                  ),
                ],
                lastManagedQueue: null,
                startupWarning: null,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AdminHomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Create Queue'), findsWidgets);
    expect(find.text('Open Analytics'), findsOneWidget);
  });
}
