import 'package:motorflow/data/models/motorflow_snapshot.dart';

abstract class MotorflowLocalStore {
  Future<MotorflowSnapshot?> readSnapshot();
  Future<void> writeSnapshot(MotorflowSnapshot snapshot);
  Future<void> close();
}
