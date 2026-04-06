import 'dart:convert';

import 'package:motorflow/data/local/isar/snapshot_record.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';

class SnapshotMapper {
  const SnapshotMapper._();

  static SnapshotRecord toRecord(MotorflowSnapshot snapshot) {
    return SnapshotRecord(
      id: MotorflowSnapshot.primaryKey,
      schemaVersion: snapshot.snapshotSchemaVersion,
      payloadJson: jsonEncode(snapshot.toMap()),
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static MotorflowSnapshot? toSnapshot(SnapshotRecord? record) {
    if (record == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(record.payloadJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return MotorflowSnapshot.fromMap(Map<String, Object?>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}
