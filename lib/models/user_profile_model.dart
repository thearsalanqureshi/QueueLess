import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_role.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    this.role,
    this.fcmTokens = const [],
    this.activeCustomerQueueId,
    this.activeCustomerTokenId,
    this.lastAdminQueueId,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final AppRole? role;
  final List<String> fcmTokens;
  final String? activeCustomerQueueId;
  final String? activeCustomerTokenId;
  final String? lastAdminQueueId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasActiveCustomerSession =>
      activeCustomerQueueId != null &&
      activeCustomerQueueId!.isNotEmpty &&
      activeCustomerTokenId != null &&
      activeCustomerTokenId!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role?.storageValue,
      'fcmTokens': fcmTokens,
      'activeCustomerQueueId': activeCustomerQueueId,
      'activeCustomerTokenId': activeCustomerTokenId,
      'lastAdminQueueId': lastAdminQueueId,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserProfileModel(
      uid: (map['uid'] as String?) ?? uid ?? '',
      role: parseAppRole(map['role'] as String?),
      fcmTokens: ((map['fcmTokens'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(growable: false),
      activeCustomerQueueId: map['activeCustomerQueueId'] as String?,
      activeCustomerTokenId: map['activeCustomerTokenId'] as String?,
      lastAdminQueueId: map['lastAdminQueueId'] as String?,
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
