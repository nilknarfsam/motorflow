import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';

class MfPageScaffold extends StatelessWidget {
  const MfPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: floatingActionButton,
      body: Padding(
        padding: const EdgeInsets.all(MotorflowSpacing.md),
        child: child,
      ),
    );
  }
}
