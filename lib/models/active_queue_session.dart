class ActiveQueueSession {
  const ActiveQueueSession({
    required this.queueId,
    required this.queueName,
    required this.tokenId,
    required this.tokenNumber,
  });

  final String queueId;
  final String queueName;
  final String tokenId;
  final int tokenNumber;

  @override
  bool operator ==(Object other) {
    return other is ActiveQueueSession &&
        other.queueId == queueId &&
        other.queueName == queueName &&
        other.tokenId == tokenId &&
        other.tokenNumber == tokenNumber;
  }

  @override
  int get hashCode => Object.hash(queueId, queueName, tokenId, tokenNumber);
}
