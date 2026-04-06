import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        return Scaffold(
          appBar: AppBar(title: const Text('Abastecimentos')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: repository.vehicles.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddFuelRecordPage(repository: repository),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
          body: items.isEmpty
              ? const Center(
                  child: Text('Nenhum abastecimento registrado.\nCadastre um veiculo primeiro.'),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final vehicle = repository.vehicleById(item.vehicleId);
                    return ListTile(
                      leading: const Icon(Icons.local_gas_station),
                      title: Text('${item.tipoCombustivel} - ${vehicle?.nome ?? 'Veiculo'}'),
                      subtitle: Text(
                        'R\$ ${item.valorTotal.toStringAsFixed(2)} | ${item.litros.toStringAsFixed(2)} L | ${_dateFormat.format(item.data)}',
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
