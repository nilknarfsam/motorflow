import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/core/widgets/mf_confirm_dialog.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/vehicle/presentation/add_vehicle_page.dart';

class VehicleDetailPage extends StatelessWidget {
  VehicleDetailPage({
    super.key,
    required this.repository,
    required this.vehicleId,
  });

  final MotorflowRepository repository;
  final String vehicleId;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final vehicle = repository.vehicleById(vehicleId);
        if (vehicle == null) {
          return const Scaffold(
            body: Center(child: Text('Veiculo nao encontrado')),
          );
        }

        final maintenances = repository.maintenancesByVehicle(vehicleId);
        final fuels = repository.fuelRecordsByVehicle(vehicleId);

        return Scaffold(
          appBar: AppBar(
            title: Text(vehicle.nome),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddVehiclePage(
                        repository: repository,
                        vehicle: vehicle,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
              ),
              IconButton(
                onPressed: () async {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veiculo excluido.')),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Excluir',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text('${vehicle.modelo} (${vehicle.ano})'),
                  subtitle: Text('KM atual: ${vehicle.kmAtual}'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ultimas manutencoes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (maintenances.isEmpty)
                const Text('Nenhuma manutencao registrada.')
              else
                ...maintenances
                    .take(3)
                    .map(
                      (m) => Card(
                        child: ListTile(
                          title: Text(m.tipo),
                          subtitle: Text(
                            '${m.descricao}\nTroca: ${m.kmTroca} km em ${_dateFormat.format(m.dataTroca)}',
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
              Text(
                'Ultimos abastecimentos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (fuels.isEmpty)
                const Text('Nenhum abastecimento registrado.')
              else
                ...fuels
                    .take(3)
                    .map(
                      (f) => Card(
                        child: ListTile(
                          title: Text(
                            '${f.tipoCombustivel} - R\$ ${f.valorTotal.toStringAsFixed(2)}',
                          ),
                          subtitle: Text(
                            '${f.litros.toStringAsFixed(2)} L em ${_dateFormat.format(f.data)}',
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
