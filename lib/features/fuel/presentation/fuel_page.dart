import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_confirm_dialog.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/fuel/presentation/add_fuel_record_page.dart';

class FuelPage extends StatelessWidget {
  FuelPage({super.key, required this.repository});

  final MotorflowRepository repository;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final items = repository.fuelRecords;
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
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: MotorflowSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final vehicle = repository.vehicleById(item.vehicleId);
                    return MfListItemCard(
                      icon: Icons.local_gas_station_outlined,
                      title:
                          '${item.tipoCombustivel} - ${vehicle?.nome ?? 'Veiculo'}',
                      subtitle:
                          'R\$ ${item.valorTotal.toStringAsFixed(2)} | ${item.litros.toStringAsFixed(2)} L | ${_dateFormat.format(item.data)}',
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
                    );
                  },
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
