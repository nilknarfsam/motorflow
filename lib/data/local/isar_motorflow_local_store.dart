import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:motorflow/data/local/isar/snapshot_record.dart';
import 'package:motorflow/data/local/mapper/snapshot_mapper.dart';
import 'package:motorflow/data/local/motorflow_local_store.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';

class IsarMotorflowLocalStore extends MotorflowLocalStore {
  IsarMotorflowLocalStore._(this._isar);

  final Isar _isar;

  static Future<IsarMotorflowLocalStore> create() async {
    final directory = await getApplicationSupportDirectory();
    final isar = await Isar.open(
      [SnapshotRecordSchema],
      directory: directory.path,
      name: 'motorflow_db',
    );
    return IsarMotorflowLocalStore._(isar);
  }

  @override
  Future<MotorflowSnapshot?> readSnapshot() async {
    try {
      final record = await _isar.snapshotRecords.get(
        MotorflowSnapshot.primaryKey,
      );
      return SnapshotMapper.toSnapshot(record);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeSnapshot(MotorflowSnapshot snapshot) async {
    try {
      final record = SnapshotMapper.toRecord(snapshot);
      await _isar.writeTxn(() async {
        await _isar.snapshotRecords.put(record);
      });
    } catch (_) {
      // Fail-safe: app keeps running even if local storage fails.
    }
  }

  @override
  Future<void> close() async {
    await _isar.close();
  }
}
