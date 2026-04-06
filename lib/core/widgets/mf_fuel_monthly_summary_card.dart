import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_compact_metric.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_models.dart';

/// Resumo executivo de combustível no mês (Material 3).
class MfFuelMonthlySummaryCard extends StatelessWidget {
  const MfFuelMonthlySummaryCard({
    super.key,
    required this.summary,
    this.title = 'Combustível',
    this.subtitle,
  });

  final FuelMetricsSummary summary;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MotorflowSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: MotorflowSpacing.xs),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: MotorflowSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MfCompactMetric(
                  label: 'Consumo médio',
                  value: _formatOptional(summary.averageConsumptionKmPerLiter, suffix: ' km/L'),
                  icon: Icons.speed_outlined,
                ),
                MfCompactMetric(
                  label: 'Custo por km',
                  value: _formatOptional(summary.averageCostPerKm, prefix: 'R\$ '),
                  icon: Icons.payments_outlined,
                ),
                MfCompactMetric(
                  label: 'Gasto no mês',
                  value: 'R\$ ${summary.totalSpentMonth.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
            const SizedBox(height: MotorflowSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: MotorflowSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MfCompactMetric(
                  label: 'Litros no mês',
                  value: '${summary.totalLitersMonth.toStringAsFixed(2)} L',
                  icon: Icons.opacity_outlined,
                ),
                MfCompactMetric(
                  label: 'Preço médio/L',
                  value: _formatOptional(summary.averagePricePerLiterMonth, prefix: 'R\$ '),
                  icon: Icons.sell_outlined,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatOptional(double? value, {String prefix = '', String suffix = ''}) {
    if (value == null) {
      return '--';
    }
    return '$prefix${value.toStringAsFixed(2)}$suffix';
  }
}
