import 'package:cloud_firestore/cloud_firestore.dart';

enum TokenStatus { waiting, served, cancelled }

class TokenModel {
  const TokenModel({
    required this.tokenId,
    required this.queueId,
    required this.tokenNumber,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  final String tokenId;
  final String queueId;
  final int tokenNumber;
  final TokenStatus status;
  final DateTime createdAt;
  final String userId;

  bool get isWaiting => status == TokenStatus.waiting;
  bool get isServed => status == TokenStatus.served;
  bool get isCancelled => status == TokenStatus.cancelled;

  TokenModel copyWith({
    String? tokenId,
    String? queueId,
    int? tokenNumber,
    TokenStatus? status,
    DateTime? createdAt,
    String? userId,
  }) {
    return TokenModel(
      tokenId: tokenId ?? this.tokenId,
      queueId: queueId ?? this.queueId,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenId': tokenId,
      'queueId': queueId,
      'tokenNumber': tokenNumber,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return TokenModel(
      tokenId: (map['tokenId'] as String?) ?? documentId ?? '',
      queueId: (map['queueId'] as String?) ?? '',
      tokenNumber: (map['tokenNumber'] as num?)?.toInt() ?? 0,
      status: TokenStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => TokenStatus.waiting,
      ),
      createdAt: _readDateTime(map['createdAt']),
      userId: (map['userId'] as String?) ?? 'anon',
    );
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
