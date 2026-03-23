class QueueMath {
  static int peopleAhead({required int currentToken, required int userToken}) {
    return (userToken - currentToken).clamp(0, 1000000);
  }

  static int waitMinutes({
    required int currentToken,
    required int userToken,
    required int avgServiceTime,
  }) {
    return peopleAhead(currentToken: currentToken, userToken: userToken) *
        avgServiceTime;
  }

  static bool isNearTurn({
    required int currentToken,
    required int userToken,
    required int threshold,
  }) {
    return peopleAhead(currentToken: currentToken, userToken: userToken) <=
        threshold;
  }

  const QueueMath._();
}
