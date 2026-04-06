import 'package:flutter/material.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/core/utils/date_formatter.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({
    super.key,
    required this.repository,
    this.maintenance,
  });

  final MotorflowRepository repository;
  final Maintenance? maintenance;

  @override
  State<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _kmTrocaController = TextEditingController();
  final _kmProximaController = TextEditingController();
  final _dataTrocaController = TextEditingController();
  final _dataProximaController = TextEditingController();
  final _custoController = TextEditingController();

  Vehicle? _selectedVehicle;
  DateTime _dataTroca = DateTime.now();
  DateTime _dataProxima = DateTime.now().add(const Duration(days: 180));
  bool get _isEditing => widget.maintenance != null;

  @override
  void initState() {
    super.initState();
    final vehicles = widget.repository.vehicles;
    final maintenance = widget.maintenance;
    if (maintenance != null) {
      _selectedVehicle = widget.repository.vehicleById(maintenance.vehicleId);
      _tipoController.text = maintenance.tipo;
      _descricaoController.text = maintenance.descricao;
      _kmTrocaController.text = maintenance.kmTroca.toString();
      _kmProximaController.text = maintenance.kmProximaTroca.toString();
      _custoController.text = maintenance.custo.toStringAsFixed(2);
      _dataTroca = maintenance.dataTroca;
      _dataProxima = maintenance.dataProximaTroca;
    } else if (vehicles.isNotEmpty) {
      _selectedVehicle = vehicles.first;
    }
    _dataTrocaController.text = formatDatePtBr(_dataTroca);
    _dataProximaController.text = formatDatePtBr(_dataProxima);
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _descricaoController.dispose();
    _kmTrocaController.dispose();
    _kmProximaController.dispose();
    _dataTrocaController.dispose();
    _dataProximaController.dispose();
    _custoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = widget.repository.vehicles;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar manutencao' : 'Nova manutencao'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Vehicle>(
                initialValue: _selectedVehicle,
                items: vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text('${v.nome} (${v.modelo})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedVehicle = value),
                decoration: const InputDecoration(labelText: 'Veiculo'),
                validator: (value) =>
                    value == null ? 'Selecione um veiculo' : null,
              ),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo'),
                validator: _requiredValidator,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descricao'),
                validator: _requiredValidator,
              ),
              TextFormField(
                controller: _kmTrocaController,
                decoration: const InputDecoration(labelText: 'KM da troca'),
                keyboardType: TextInputType.number,
                validator: _intValidator,
              ),
              TextFormField(
                controller: _kmProximaController,
                decoration: const InputDecoration(
                  labelText: 'KM proxima troca',
                ),
                keyboardType: TextInputType.number,
                validator: _intValidator,
              ),
              _DateInput(
                label: 'Data da troca',
                controller: _dataTrocaController,
                onTap: () async {
                  final date = await _pickDate(_dataTroca);
                  if (date == null) return;
                  setState(() {
                    _dataTroca = date;
                    _dataTrocaController.text = formatDatePtBr(date);
                  });
                },
              ),
              _DateInput(
                label: 'Data proxima troca',
                controller: _dataProximaController,
                onTap: () async {
                  final date = await _pickDate(_dataProxima);
                  if (date == null) return;
                  setState(() {
                    _dataProxima = date;
                    _dataProximaController.text = formatDatePtBr(date);
                  });
                },
              ),
              TextFormField(
                controller: _custoController,
                decoration: const InputDecoration(labelText: 'Custo'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _doubleValidator,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Salvar alteracoes' : 'Salvar manutencao',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    if (int.tryParse(value) == null) {
      return 'Numero inteiro invalido';
    }
    return null;
  }

  String? _doubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Numero invalido';
    }
    return null;
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _selectedVehicle == null) {
      return;
    }
    if (_isEditing) {
      widget.repository.updateMaintenance(
        id: widget.maintenance!.id,
        vehicleId: _selectedVehicle!.id,
        tipo: _tipoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        kmTroca: int.parse(_kmTrocaController.text),
        dataTroca: _dataTroca,
        kmProximaTroca: int.parse(_kmProximaController.text),
        dataProximaTroca: _dataProxima,
        custo: double.parse(_custoController.text.replaceAll(',', '.')),
      );
    } else {
      widget.repository.addMaintenance(
        vehicleId: _selectedVehicle!.id,
        tipo: _tipoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        kmTroca: int.parse(_kmTrocaController.text),
        dataTroca: _dataTroca,
        kmProximaTroca: int.parse(_kmProximaController.text),
        dataProximaTroca: _dataProxima,
        custo: double.parse(_custoController.text.replaceAll(',', '.')),
      );
    }
    Navigator.of(context).pop();
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatorio';
        }
        return null;
      },
    );
  }
}
