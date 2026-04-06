import 'package:motorflow/data/local/motorflow_local_store.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';

class MemoryMotorflowLocalStore extends MotorflowLocalStore {
  MotorflowSnapshot? _snapshot;

  @override
  MotorflowSnapshot? readSnapshot() => _snapshot;

  @override
  void writeSnapshot(MotorflowSnapshot snapshot) {
    _snapshot = snapshot;
  }
}
