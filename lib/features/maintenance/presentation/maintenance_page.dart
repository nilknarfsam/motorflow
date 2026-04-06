import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_empty_state.dart';
import 'package:motorflow/core/widgets/mf_list_item_card.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
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
                    );
                  },
                ),
        );
      },
    );
  }
}
