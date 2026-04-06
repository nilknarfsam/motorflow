import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

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
          appBar: AppBar(title: Text(vehicle.nome)),
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
              Text('Ultimas manutencoes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (maintenances.isEmpty)
                const Text('Nenhuma manutencao registrada.')
              else
                ...maintenances.take(3).map(
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
              Text('Ultimos abastecimentos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (fuels.isEmpty)
                const Text('Nenhum abastecimento registrado.')
              else
                ...fuels.take(3).map(
                  (f) => Card(
                    child: ListTile(
                      title: Text('${f.tipoCombustivel} - R\$ ${f.valorTotal.toStringAsFixed(2)}'),
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
