import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_metric_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/core/widgets/mf_section_header.dart';
import 'package:motorflow/core/widgets/mf_status_chip.dart';
import 'package:motorflow/domain/alerts/maintenance_alert.dart';
import 'package:motorflow/domain/alerts/maintenance_alert_center.dart';
import 'package:motorflow/domain/alerts/maintenance_alert_summary.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_center.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_models.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _gasolinaController = TextEditingController();
  final _alertCenter = const MaintenanceAlertCenter();
  final _fuelMetricsCenter = const FuelMetricsCenter();

  @override
  void initState() {
    super.initState();
    _gasolinaController.text = widget
        .repository
        .fuelSettings
        .precoPadraoGasolina
        .toStringAsFixed(2);
  }

  @override
  void dispose() {
    _gasolinaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        final fuelSettings = widget.repository.fuelSettings;
        final summary = _alertCenter.buildSummary(
          maintenances: widget.repository.maintenances,
          vehicles: widget.repository.vehicles,
        );
        final fuelSummary = _fuelMetricsCenter.buildSummary(
          records: widget.repository.fuelRecords,
        );
        return MfPageScaffold(
          title: 'Dashboard',
          child: ListView(
            children: [
              const MfSectionHeader(
                title: 'Visao geral',
                subtitle: 'Controle de frota, manutencoes e abastecimentos.',
              ),
              const SizedBox(height: MotorflowSpacing.md),
              MfMetricCard(
                title: 'Veiculos',
                value: '${widget.repository.vehicles.length}',
                icon: Icons.directions_car_filled_outlined,
              ),
              const SizedBox(height: MotorflowSpacing.sm),
              MfMetricCard(
                title: 'Manutencoes',
                value: '${widget.repository.maintenances.length}',
                icon: Icons.build_circle_outlined,
              ),
              const SizedBox(height: MotorflowSpacing.sm),
              MfMetricCard(
                title: 'Abastecimentos',
                value: '${widget.repository.fuelRecords.length}',
                icon: Icons.local_gas_station_outlined,
              ),
              const SizedBox(height: MotorflowSpacing.lg),
              _MaintenanceAlertsCard(summary: summary),
              const SizedBox(height: MotorflowSpacing.lg),
              _FuelMetricsCard(summary: fuelSummary),
              const SizedBox(height: MotorflowSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(MotorflowSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preco padrao gasolina',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: MotorflowSpacing.sm),
                      TextFormField(
                        controller: _gasolinaController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(prefixText: 'R\$ '),
                      ),
                      const SizedBox(height: MotorflowSpacing.sm),
                      FilledButton(
                        onPressed: () {
                          final parsed = double.tryParse(
                            _gasolinaController.text.replaceAll(',', '.'),
                          );
                          if (parsed == null || parsed <= 0) {
                            _showError('Informe um valor valido.');
                            return;
                          }
                          widget.repository.updateFuelSettings(
                            precoPadraoGasolina: parsed,
                          );
                          _gasolinaController.text = widget
                              .repository
                              .fuelSettings
                              .precoPadraoGasolina
                              .toStringAsFixed(2);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preco padrao atualizado.'),
                            ),
                          );
                        },
                        child: const Text('Salvar preco'),
                      ),
                      const SizedBox(height: MotorflowSpacing.xs),
                      Text(
                        'Etanol: R\$ ${fuelSettings.precoPadraoEtanol.toStringAsFixed(2)} | Diesel: R\$ ${fuelSettings.precoPadraoDiesel.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FuelMetricsCard extends StatelessWidget {
  const _FuelMetricsCard({required this.summary});

  final FuelMetricsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MotorflowSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inteligencia de combustivel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MotorflowSpacing.sm),
            Wrap(
              spacing: MotorflowSpacing.sm,
              runSpacing: MotorflowSpacing.sm,
              children: [
                _FuelMetricTile(
                  label: 'Consumo medio',
                  value: _formatMetric(
                    summary.averageConsumptionKmPerLiter,
                    suffix: ' km/L',
                  ),
                ),
                _FuelMetricTile(
                  label: 'Custo por km',
                  value: _formatMetric(
                    summary.averageCostPerKm,
                    prefix: 'R\$ ',
                  ),
                ),
                _FuelMetricTile(
                  label: 'Gasto no mes',
                  value: 'R\$ ${summary.totalSpentMonth.toStringAsFixed(2)}',
                ),
                _FuelMetricTile(
                  label: 'Litros no mes',
                  value: '${summary.totalLitersMonth.toStringAsFixed(2)} L',
                ),
                _FuelMetricTile(
                  label: 'Preco medio/L',
                  value: _formatMetric(
                    summary.averagePricePerLiterMonth,
                    prefix: 'R\$ ',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMetric(
    double? value, {
    String prefix = '',
    String suffix = '',
  }) {
    if (value == null) {
      return '--';
    }
    return '$prefix${value.toStringAsFixed(2)}$suffix';
  }
}

class _FuelMetricTile extends StatelessWidget {
  const _FuelMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: MotorflowSpacing.xxs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _MaintenanceAlertsCard extends StatelessWidget {
  const _MaintenanceAlertsCard({required this.summary});

  final MaintenanceAlertSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MotorflowSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas de manutencao',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MotorflowSpacing.xs),
            Text(
              '${summary.totalAlerts} alerta(s) ativo(s) de ${summary.total} manutencao(oes).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: MotorflowSpacing.sm),
            Wrap(
              spacing: MotorflowSpacing.xs,
              runSpacing: MotorflowSpacing.xs,
              children: [
                _LabeledStatusChip(
                  label: 'Vencido',
                  count: summary.overdue,
                  status: MaintenanceAlertStatus.overdue,
                ),
                _LabeledStatusChip(
                  label: 'Proximo',
                  count: summary.dueSoon,
                  status: MaintenanceAlertStatus.dueSoon,
                ),
                _LabeledStatusChip(
                  label: 'Em dia',
                  count: summary.onTime,
                  status: MaintenanceAlertStatus.onTime,
                ),
                _LabeledStatusChip(
                  label: 'Sem alerta',
                  count: summary.neutral,
                  status: MaintenanceAlertStatus.neutral,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledStatusChip extends StatelessWidget {
  const _LabeledStatusChip({
    required this.label,
    required this.count,
    required this.status,
  });

  final String label;
  final int count;
  final MaintenanceAlertStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MfStatusChip(status: status),
        const SizedBox(width: MotorflowSpacing.xs),
        Text('$label: $count'),
      ],
    );
  }
}
