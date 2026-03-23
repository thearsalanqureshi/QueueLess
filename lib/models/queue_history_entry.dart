import 'package:hive/hive.dart';

class QueueHistoryEntry {
  const QueueHistoryEntry({
    required this.id,
    required this.queueId,
    required this.queueName,
    required this.createdAt,
    required this.role,
    required this.statusLabel,
    this.tokenNumber,
  });

  final String id;
  final String queueId;
  final String queueName;
  final int? tokenNumber;
  final DateTime createdAt;
  final String role;
  final String statusLabel;

  static const String customerRole = 'Customer';
  static const String adminRole = 'Admin';

  bool get isCustomerEntry => role == customerRole;
  bool get isAdminEntry => role == adminRole;
}

class QueueHistoryEntryAdapter extends TypeAdapter<QueueHistoryEntry> {
  static const int typeIdValue = 21;

  @override
  final int typeId = typeIdValue;

  @override
  QueueHistoryEntry read(BinaryReader reader) {
    final totalFields = reader.readByte();
    final values = <int, dynamic>{};
    for (var index = 0; index < totalFields; index++) {
      values[reader.readByte()] = reader.read();
    }

    return QueueHistoryEntry(
      id: values[0] as String,
      queueId: values[1] as String,
      queueName: values[2] as String,
      tokenNumber: values[3] as int?,
      createdAt: values[4] as DateTime,
      role: values[5] as String,
      statusLabel: values[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QueueHistoryEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.queueId)
      ..writeByte(2)
      ..write(obj.queueName)
      ..writeByte(3)
      ..write(obj.tokenNumber)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.statusLabel);
  }
}
