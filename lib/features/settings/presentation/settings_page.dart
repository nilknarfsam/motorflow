import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';
import 'package:motorflow/core/widgets/mf_page_scaffold.dart';
import 'package:motorflow/core/widgets/mf_section_header.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/settings/presentation/widgets/settings_group.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  Widget build(BuildContext context) {
    final fuel = repository.fuelSettings;
    return MfPageScaffold(
      title: 'Ajustes',
      child: ListView(
        children: [
          const MfSectionHeader(
            title: 'Preferências',
            subtitle: 'Ajustes visuais e operacionais do MotorFlow.',
          ),
          const SizedBox(height: MotorflowSpacing.md),
          SettingsGroup(
            title: 'Combustível padrão',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_gas_station_outlined),
                title: const Text('Gasolina'),
                trailing: Text(
                  'R\$ ${fuel.precoPadraoGasolina.toStringAsFixed(2)}',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.energy_savings_leaf_outlined),
                title: const Text('Etanol'),
                trailing: Text(
                  'R\$ ${fuel.precoPadraoEtanol.toStringAsFixed(2)}',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Diesel'),
                trailing: Text(
                  'R\$ ${fuel.precoPadraoDiesel.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: MotorflowSpacing.md),
          const SettingsGroup(
            title: 'Roadmap técnico',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.storage_outlined),
                title: Text('Persistência local (Isar)'),
                subtitle: Text(
                  'Dados salvos no dispositivo com Isar; base preparada para evoluir.',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.notifications_active_outlined),
                title: Text('Lembretes inteligentes'),
                subtitle: Text('Alertas por quilometragem e data nas manutenções.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
