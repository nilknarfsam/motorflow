import 'package:flutter/material.dart';
import 'package:motorflow/domain/alerts/maintenance_alert.dart';

class MfStatusChip extends StatelessWidget {
  const MfStatusChip({super.key, required this.status});

  final MaintenanceAlertStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      MaintenanceAlertStatus.overdue => (
        'Vencido',
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      MaintenanceAlertStatus.dueSoon => (
        'Proximo',
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      MaintenanceAlertStatus.onTime => (
        'Em dia',
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      MaintenanceAlertStatus.neutral => (
        'Sem alerta',
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
      backgroundColor: background,
      side: BorderSide.none,
      label: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
