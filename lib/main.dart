import 'package:flutter/material.dart';
import 'package:motorflow/data/repositories/in_memory_motorflow_repository.dart';
import 'package:motorflow/presentation/app.dart';

void main() {
  final repository = InMemoryMotorflowRepository();
  runApp(MotorflowApp(repository: repository));
}
