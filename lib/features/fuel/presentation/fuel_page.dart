import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_confirm_dialog.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_center.dart';
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
        final insights = _fuelMetricsCenter.buildRecordInsights(records: items);
        final insightByRecordId = {
          for (final insight in insights) insight.recordId: insight,
        };
        final monthlyByVehicle = _fuelMetricsCenter
            .buildVehicleMonthlySummaries(records: items);
        return MfPageScaffold(
          title: 'Abastecimentos',
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
            label: const Text('Adicionar'),
          ),
          child: items.isEmpty
              ? const MfEmptyState(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Nenhum abastecimento registrado',
                  message: 'Cadastre um veiculo para registrar abastecimentos.',
                )
              : ListView(
                  children: [
                    if (monthlyByVehicle.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(MotorflowSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumo mensal por veiculo',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: MotorflowSpacing.sm),
                              ...monthlyByVehicle.take(3).map((summary) {
                                final vehicle = repository.vehicleById(
                                  summary.vehicleId,
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: MotorflowSpacing.xs,
                                  ),
                                  child: Text(
                                    '${vehicle?.nome ?? 'Veiculo'}: R\$ ${summary.totalSpentMonth.toStringAsFixed(2)} | ${summary.totalLitersMonth.toStringAsFixed(2)} L',
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: MotorflowSpacing.sm),
                    ],
                    ...List.generate(items.length, (index) {
                      final item = items[index];
                      final vehicle = repository.vehicleById(item.vehicleId);
                      final insight = insightByRecordId[item.id];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: MotorflowSpacing.sm,
                        ),
                        child: MfListItemCard(
                          icon: Icons.local_gas_station_outlined,
                          title:
                              '${item.tipoCombustivel} - ${vehicle?.nome ?? 'Veiculo'}',
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
          'Deseja excluir este abastecimento? Essa acao nao pode ser desfeita.',
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
    ).showSnackBar(const SnackBar(content: Text('Abastecimento excluido.')));
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
