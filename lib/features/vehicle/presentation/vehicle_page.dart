import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_confirm_dialog.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/vehicle/presentation/add_vehicle_page.dart';
import 'package:motorflow/features/vehicle/presentation/vehicle_detail_page.dart';

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final vehicles = repository.vehicles;
        return MfPageScaffold(
          title: 'Veiculos',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddVehiclePage(repository: repository),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar'),
          ),
          child: vehicles.isEmpty
              ? const MfEmptyState(
                  icon: Icons.directions_car_outlined,
                  title: 'Nenhum veiculo cadastrado',
                  message: 'Cadastre seu primeiro veiculo para iniciar.',
                )
              : ListView.separated(
                  itemCount: vehicles.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: MotorflowSpacing.sm),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return MfListItemCard(
                      icon: Icons.directions_car_outlined,
                      title: vehicle.nome,
                      subtitle:
                          '${vehicle.modelo} | ${vehicle.ano} | ${vehicle.kmAtual} km',
                      trailing: PopupMenuButton<_VehicleAction>(
                        onSelected: (action) async {
                          if (action == _VehicleAction.details) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VehicleDetailPage(
                                  repository: repository,
                                  vehicleId: vehicle.id,
                                ),
                              ),
                            );
                            return;
                          }
                          if (action == _VehicleAction.edit) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddVehiclePage(
                                  repository: repository,
                                  vehicle: vehicle,
                                ),
                              ),
                            );
                            return;
                          }
                          await _deleteVehicleWithConfirm(context, vehicle);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _VehicleAction.details,
                            child: Text('Detalhes'),
                          ),
                          PopupMenuItem(
                            value: _VehicleAction.edit,
                            child: Text('Editar'),
                          ),
                          PopupMenuItem(
                            value: _VehicleAction.delete,
                            child: Text('Excluir'),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VehicleDetailPage(
                              repository: repository,
                              vehicleId: vehicle.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _deleteVehicleWithConfirm(
    BuildContext context,
    Vehicle vehicle,
  ) async {
    final confirmed = await showMfConfirmDialog(
      context: context,
      title: 'Excluir veiculo',
      message:
          'Deseja excluir ${vehicle.nome}? As manutencoes e abastecimentos vinculados tambem serao removidos.',
    );
    if (!confirmed) {
      return;
    }
    repository.deleteVehicle(vehicle.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Veiculo excluido.')));
  }
}

enum _VehicleAction { details, edit, delete }
