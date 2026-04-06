import 'package:flutter/material.dart';
import 'package:motorflow/data/local/isar_motorflow_local_store.dart';
import 'package:motorflow/data/repositories/in_memory_motorflow_repository.dart';
import 'package:motorflow/presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStore = await IsarMotorflowLocalStore.create();
  final repository = await InMemoryMotorflowRepository.create(
    localStore: localStore,
  );
  runApp(MotorflowApp(repository: repository));
}
