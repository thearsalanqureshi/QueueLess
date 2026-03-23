import 'package:cloud_firestore/cloud_firestore.dart';

enum QueueLifecycleStatus { active, paused, ended }

class QueueModel {
  const QueueModel({
    required this.queueId,
    required this.adminId,
    required this.name,
    required this.avgServiceTime,
    required this.currentToken,
    required this.lastIssuedToken,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String queueId;
  final String adminId;
  final String name;
  final int avgServiceTime;
  final int currentToken;
  final int lastIssuedToken;
  final QueueLifecycleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPaused => status == QueueLifecycleStatus.paused;
  bool get isEnded => status == QueueLifecycleStatus.ended;

  QueueModel copyWith({
    String? queueId,
    String? adminId,
    String? name,
    int? avgServiceTime,
    int? currentToken,
    int? lastIssuedToken,
    QueueLifecycleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QueueModel(
      queueId: queueId ?? this.queueId,
      adminId: adminId ?? this.adminId,
      name: name ?? this.name,
      avgServiceTime: avgServiceTime ?? this.avgServiceTime,
      currentToken: currentToken ?? this.currentToken,
      lastIssuedToken: lastIssuedToken ?? this.lastIssuedToken,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'queueId': queueId,
      'adminId': adminId,
      'name': name,
      'avgServiceTime': avgServiceTime,
      'currentToken': currentToken,
      'lastIssuedToken': lastIssuedToken,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory QueueModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return QueueModel(
      queueId: (map['queueId'] as String?) ?? documentId ?? '',
      adminId: (map['adminId'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Queue',
      avgServiceTime: (map['avgServiceTime'] as num?)?.toInt() ?? 5,
      currentToken: (map['currentToken'] as num?)?.toInt() ?? 0,
      lastIssuedToken:
          (map['lastIssuedToken'] as num?)?.toInt() ??
          (map['currentToken'] as num?)?.toInt() ??
          0,
      status: QueueLifecycleStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => QueueLifecycleStatus.active,
      ),
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
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
