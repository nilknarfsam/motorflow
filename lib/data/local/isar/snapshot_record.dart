import 'package:isar/isar.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';

part 'snapshot_record.g.dart';

@collection
class SnapshotRecord {
  SnapshotRecord({
    this.id = MotorflowSnapshot.primaryKey,
    required this.schemaVersion,
    required this.payloadJson,
    required this.updatedAtEpochMs,
  });

  Id id;
  int schemaVersion;
  String payloadJson;
  int updatedAtEpochMs;
}
