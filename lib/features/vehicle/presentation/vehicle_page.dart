import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
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
                      trailing: const Icon(Icons.chevron_right),
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
}
