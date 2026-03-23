import 'package:flutter_test/flutter_test.dart';
import 'package:queueless/core/utils/queue_math.dart';

void main() {
  test('wait time uses tokens ahead multiplied by average service time', () {
    expect(
      QueueMath.waitMinutes(currentToken: 5, userToken: 10, avgServiceTime: 4),
      20,
    );
  });

  test('people ahead never becomes negative', () {
    expect(QueueMath.peopleAhead(currentToken: 12, userToken: 10), 0);
  });
}
