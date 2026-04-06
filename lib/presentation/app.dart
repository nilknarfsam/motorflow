import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_theme.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/presentation/home_shell.dart';

class MotorflowApp extends StatelessWidget {
  const MotorflowApp({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotorFlow',
      debugShowCheckedModeBanner: false,
      theme: MotorflowTheme.light(),
      home: HomeShell(repository: repository),
    );
  }
}
