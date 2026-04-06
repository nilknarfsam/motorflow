import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_confirm_dialog.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_fuel_monthly_summary_card.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_center.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_models.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/fuel/presentation/add_fuel_record_page.dart';

class FuelPage extends StatelessWidget {
  FuelPage({super.key, required this.repository});

  final MotorflowRepository repository;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final FuelMetricsCenter _fuelMetricsCenter = const FuelMetricsCenter();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final items = repository.fuelRecords;
        final sortedItems = [...items]
          ..sort((a, b) {
            final byDate = b.data.compareTo(a.data);
            if (byDate != 0) {
              return byDate;
            }
            return b.kmAtual.compareTo(a.kmAtual);
          });
        final fuelSummary = _fuelMetricsCenter.buildSummary(records: items);
        final insights = _fuelMetricsCenter.buildRecordInsights(records: items);
        final insightByRecordId = {
          for (final insight in insights) insight.recordId: insight,
        };
        final monthlyByVehicle = _fuelMetricsCenter
            .buildVehicleMonthlySummaries(records: items);
        final rollups = _fuelMetricsCenter.buildVehicleFuelRollups(
          records: items,
        );
        final rollupsWithData =
            rollups.where((r) => r.validPairCount > 0).toList();

        return MfPageScaffold(
          title: 'Combustível',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: repository.vehicles.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddFuelRecordPage(repository: repository),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Novo abastecimento'),
          ),
          child: items.isEmpty
              ? const MfEmptyState(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Nenhum abastecimento registrado',
                  message:
                      'Cadastre um veículo antes de registrar abastecimentos.',
                )
              : ListView(
                  children: [
                    MfFuelMonthlySummaryCard(
                      summary: fuelSummary,
                      subtitle:
                          'Mês atual. Consumo e custo por km exigem dois abastecimentos válidos no mesmo veículo.',
                    ),
                    if (rollupsWithData.isNotEmpty) ...[
                      const SizedBox(height: MotorflowSpacing.sm),
                      _VehicleHistoryCard(
                        repository: repository,
                        rollups: rollupsWithData,
                      ),
                    ],
                    if (monthlyByVehicle.isNotEmpty) ...[
                      const SizedBox(height: MotorflowSpacing.sm),
                      _VehicleMonthlyCard(
                        repository: repository,
                        summaries: monthlyByVehicle,
                      ),
                    ],
                    const SizedBox(height: MotorflowSpacing.md),
                    Text(
                      'Registros',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: MotorflowSpacing.sm),
                    ...sortedItems.map((item) {
                      final vehicle = repository.vehicleById(item.vehicleId);
                      final insight = insightByRecordId[item.id];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: MotorflowSpacing.sm,
                        ),
                        child: MfListItemCard(
                          icon: Icons.local_gas_station_outlined,
                          title:
                              '${item.tipoCombustivel} — ${vehicle?.nome ?? 'Veículo'}',
                          subtitle:
                              'R\$ ${item.valorTotal.toStringAsFixed(2)} | ${item.litros.toStringAsFixed(2)} L | ${_dateFormat.format(item.data)}',
                          footer: insight == null
                              ? null
                              : Wrap(
                                  spacing: MotorflowSpacing.xs,
                                  runSpacing: MotorflowSpacing.xs,
                                  children: [
                                    _DerivedChip(
                                      label:
                                          'Consumo ${insight.consumptionKmPerLiter.toStringAsFixed(2)} km/L',
                                    ),
                                    _DerivedChip(
                                      label:
                                          'Custo/km R\$ ${insight.costPerKm.toStringAsFixed(2)}',
                                    ),
                                    _DerivedChip(
                                      label:
                                          '${insight.distanceKm} km desde o anterior',
                                    ),
                                  ],
                                ),
                          trailing: PopupMenuButton<_FuelAction>(
                            onSelected: (action) async {
                              if (action == _FuelAction.edit) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddFuelRecordPage(
                                      repository: repository,
                                      fuelRecord: item,
                                    ),
                                  ),
                                );
                                return;
                              }
                              await _deleteFuelWithConfirm(context, item);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _FuelAction.edit,
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: _FuelAction.delete,
                                child: Text('Excluir'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _deleteFuelWithConfirm(
    BuildContext context,
    FuelRecord fuelRecord,
  ) async {
    final confirmed = await showMfConfirmDialog(
      context: context,
      title: 'Excluir abastecimento',
      message:
          'Deseja excluir este abastecimento? Essa ação não pode ser desfeita.',
    );
    if (!confirmed) {
      return;
    }
    repository.deleteFuelRecord(fuelRecord.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Abastecimento excluído.')));
  }
}

enum _FuelAction { edit, delete }

class _DerivedChip extends StatelessWidget {
  const _DerivedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(vertical: -3, horizontal: -3),
      backgroundColor: scheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}

class _VehicleMonthlyCard extends StatelessWidget {
  const _VehicleMonthlyCard({
    required this.repository,
    required this.summaries,
  });

  final MotorflowRepository repository;
  final List<VehicleFuelMonthlySummary> summaries;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MotorflowSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo mensal por veículo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MotorflowSpacing.sm),
            ...summaries.map((summary) {
              final vehicle = repository.vehicleById(summary.vehicleId);
              final name = vehicle?.nome ?? 'Veículo';
              final base =
                  '$name: R\$ ${summary.totalSpentMonth.toStringAsFixed(2)} · ${summary.totalLitersMonth.toStringAsFixed(2)} L';
              final extra = _monthlyDerivedLine(summary);
              return Padding(
                padding: const EdgeInsets.only(bottom: MotorflowSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(base, style: Theme.of(context).textTheme.bodyMedium),
                    if (extra != null)
                      Text(
                        extra,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String? _monthlyDerivedLine(VehicleFuelMonthlySummary s) {
    final parts = <String>[];
    if (s.averageConsumptionKmPerLiter != null) {
      parts.add(
        'Consumo médio ${s.averageConsumptionKmPerLiter!.toStringAsFixed(2)} km/L',
      );
    }
    if (s.averageCostPerKm != null) {
      parts.add('Custo/km R\$ ${s.averageCostPerKm!.toStringAsFixed(2)}');
    }
    if (s.totalLitersMonth > 0) {
      parts.add(
        'Preço médio R\$ ${s.averagePricePerLiterMonth.toStringAsFixed(2)}/L',
      );
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' · ');
  }
}

class _VehicleHistoryCard extends StatelessWidget {
  const _VehicleHistoryCard({
    required this.repository,
    required this.rollups,
  });

  final MotorflowRepository repository;
  final List<VehicleFuelRollup> rollups;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MotorflowSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Médias por veículo (histórico)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MotorflowSpacing.xs),
            Text(
              'Com base em ${rollups.fold<int>(0, (a, r) => a + r.validPairCount)} intervalo(s) válido(s).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: MotorflowSpacing.sm),
            ...rollups.map((r) {
              final vehicle = repository.vehicleById(r.vehicleId);
              final name = vehicle?.nome ?? 'Veículo';
              final cons = r.averageConsumptionKmPerLiter != null
                  ? '${r.averageConsumptionKmPerLiter!.toStringAsFixed(2)} km/L'
                  : '—';
              final cost = r.averageCostPerKm != null
                  ? 'R\$ ${r.averageCostPerKm!.toStringAsFixed(2)}'
                  : '—';
              return Padding(
                padding: const EdgeInsets.only(bottom: MotorflowSpacing.xs),
                child: Text(
                  '$name: $cons · $cost/km (${r.validPairCount} intervalo${r.validPairCount == 1 ? '' : 's'})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
