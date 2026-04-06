import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_confirm_dialog.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/core/widgets/mf_status_chip.dart';
import 'package:motorflow/domain/alerts/maintenance_alert.dart';
import 'package:motorflow/domain/alerts/maintenance_alert_center.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/maintenance/presentation/add_maintenance_page.dart';

class MaintenancePage extends StatelessWidget {
  MaintenancePage({super.key, required this.repository});

  final MotorflowRepository repository;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final MaintenanceAlertCenter _alertCenter = const MaintenanceAlertCenter();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final items = repository.maintenances;
        final alerts = _alertCenter.buildAlerts(
          maintenances: items,
          vehicles: repository.vehicles,
        );
        final statusByMaintenanceId = {
          for (final alert in alerts) alert.maintenanceId: alert.status,
        };
        return MfPageScaffold(
          title: 'Manutencoes',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: repository.vehicles.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddMaintenancePage(repository: repository),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
          child: items.isEmpty
              ? const MfEmptyState(
                  icon: Icons.build_circle_outlined,
                  title: 'Nenhuma manutencao registrada',
                  message: 'Cadastre um veiculo para registrar manutencoes.',
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: MotorflowSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final vehicle = repository.vehicleById(item.vehicleId);
                    return MfListItemCard(
                      icon: Icons.build_circle_outlined,
                      title: '${item.tipo} - ${vehicle?.nome ?? 'Veiculo'}',
                      subtitle:
                          '${item.descricao}\nR\$ ${item.custo.toStringAsFixed(2)} | ${_dateFormat.format(item.dataTroca)}',
                      footer: Align(
                        alignment: Alignment.centerLeft,
                        child: MfStatusChip(
                          status:
                              statusByMaintenanceId[item.id] ??
                              MaintenanceAlertStatus.neutral,
                        ),
                      ),
                      trailing: PopupMenuButton<_MaintenanceAction>(
                        onSelected: (action) async {
                          if (action == _MaintenanceAction.edit) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMaintenancePage(
                                  repository: repository,
                                  maintenance: item,
                                ),
                              ),
                            );
                            return;
                          }
                          await _deleteMaintenanceWithConfirm(context, item);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _MaintenanceAction.edit,
                            child: Text('Editar'),
                          ),
                          PopupMenuItem(
                            value: _MaintenanceAction.delete,
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

  Future<void> _deleteMaintenanceWithConfirm(
    BuildContext context,
    Maintenance maintenance,
  ) async {
    final confirmed = await showMfConfirmDialog(
      context: context,
      title: 'Excluir manutencao',
      message:
          'Deseja excluir esta manutencao? Essa acao nao pode ser desfeita.',
    );
    if (!confirmed) {
      return;
    }
    repository.deleteMaintenance(maintenance.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Manutencao excluida.')));
  }
}

enum _MaintenanceAction { edit, delete }
