import 'package:motorflow/data/models/motorflow_snapshot.dart';

abstract class MotorflowLocalStore {
  MotorflowSnapshot? readSnapshot();
  void writeSnapshot(MotorflowSnapshot snapshot);
}
