import 'package:flutter/material.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key, required this.repository, this.vehicle});

  final MotorflowRepository repository;
  final Vehicle? vehicle;

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _kmAtualController = TextEditingController();

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    if (vehicle != null) {
      _nomeController.text = vehicle.nome;
      _modeloController.text = vehicle.modelo;
      _anoController.text = vehicle.ano.toString();
      _kmAtualController.text = vehicle.kmAtual.toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _kmAtualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar veiculo' : 'Novo veiculo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: _requiredValidator,
              ),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: _requiredValidator,
              ),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: _numberValidator,
              ),
              TextFormField(
                controller: _kmAtualController,
                decoration: const InputDecoration(labelText: 'KM atual'),
                keyboardType: TextInputType.number,
                validator: _numberValidator,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Salvar alteracoes' : 'Salvar veiculo',
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

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    if (int.tryParse(value) == null) {
      return 'Digite um numero inteiro';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditing) {
      widget.repository.updateVehicle(
        id: widget.vehicle!.id,
        nome: _nomeController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: int.parse(_anoController.text),
        kmAtual: int.parse(_kmAtualController.text),
      );
    } else {
      widget.repository.addVehicle(
        nome: _nomeController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: int.parse(_anoController.text),
        kmAtual: int.parse(_kmAtualController.text),
      );
    }
    Navigator.of(context).pop();
  }
}
