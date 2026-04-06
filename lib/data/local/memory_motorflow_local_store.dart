import 'package:motorflow/data/local/motorflow_local_store.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';

class MemoryMotorflowLocalStore extends MotorflowLocalStore {
  MotorflowSnapshot? _snapshot;

  @override
  Future<MotorflowSnapshot?> readSnapshot() async => _snapshot;

  @override
  Future<void> writeSnapshot(MotorflowSnapshot snapshot) async {
    _snapshot = snapshot;
  }

  @override
  Future<void> close() async {}
}
