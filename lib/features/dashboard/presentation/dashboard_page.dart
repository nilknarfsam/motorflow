import 'package:flutter/material.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _gasolinaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gasolinaController.text =
        widget.repository.fuelSettings.precoPadraoGasolina.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _gasolinaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        final fuelSettings = widget.repository.fuelSettings;
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      title: 'Veiculos',
                      value: '${widget.repository.vehicles.length}',
                    ),
                    _MetricCard(
                      title: 'Manutencoes',
                      value: '${widget.repository.maintenances.length}',
                    ),
                    _MetricCard(
                      title: 'Abastecimentos',
                      value: '${widget.repository.fuelRecords.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preco padrao gasolina',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _gasolinaController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            prefixText: 'R\$ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: () {
                            final parsed = double.tryParse(
                              _gasolinaController.text.replaceAll(',', '.'),
                            );
                            if (parsed == null || parsed <= 0) {
                              _showError('Informe um valor valido.');
                              return;
                            }
                            widget.repository.updateFuelSettings(
                              precoPadraoGasolina: parsed,
                            );
                            _gasolinaController.text =
                                fuelSettings.precoPadraoGasolina
                                    .toStringAsFixed(2);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Preco padrao atualizado.'),
                              ),
                            );
                          },
                          child: const Text('Salvar preco'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Etanol: R\$ ${fuelSettings.precoPadraoEtanol.toStringAsFixed(2)} | Diesel: R\$ ${fuelSettings.precoPadraoDiesel.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
