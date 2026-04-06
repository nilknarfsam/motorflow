import 'package:flutter/material.dart';
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
        return Scaffold(
          appBar: AppBar(title: const Text('Veiculos')),
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
          body: vehicles.isEmpty
              ? const Center(child: Text('Nenhum veiculo cadastrado.'))
              : ListView.separated(
                  itemCount: vehicles.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text(vehicle.nome),
                      subtitle: Text(
                        '${vehicle.modelo} | ${vehicle.ano} | ${vehicle.kmAtual} km',
                      ),
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
