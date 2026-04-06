import 'package:flutter/material.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _kmAtualController = TextEditingController();

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
      appBar: AppBar(title: const Text('Novo veiculo')),
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
                child: const Text('Salvar veiculo'),
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
    widget.repository.addVehicle(
      nome: _nomeController.text.trim(),
      modelo: _modeloController.text.trim(),
      ano: int.parse(_anoController.text),
      kmAtual: int.parse(_kmAtualController.text),
    );
    Navigator.of(context).pop();
  }
}
