import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/maintenance/presentation/add_maintenance_page.dart';

class MaintenancePage extends StatelessWidget {
  MaintenancePage({super.key, required this.repository});

  final MotorflowRepository repository;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final items = repository.maintenances;
        return Scaffold(
          appBar: AppBar(title: const Text('Manutencoes')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: repository.vehicles.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddMaintenancePage(repository: repository),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
          body: items.isEmpty
              ? const Center(
                  child: Text('Nenhuma manutencao registrada.\nCadastre um veiculo primeiro.'),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final vehicle = repository.vehicleById(item.vehicleId);
                    return ListTile(
                      leading: const Icon(Icons.build_circle_outlined),
                      title: Text('${item.tipo} - ${vehicle?.nome ?? 'Veiculo'}'),
                      subtitle: Text(
                        '${item.descricao}\nR\$ ${item.custo.toStringAsFixed(2)} | ${_dateFormat.format(item.dataTroca)}',
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
        );
      },
    );
  }
}
