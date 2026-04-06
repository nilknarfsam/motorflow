import 'package:flutter/material.dart';
import 'package:motorflow/core/utils/date_formatter.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class AddFuelRecordPage extends StatefulWidget {
  const AddFuelRecordPage({
    super.key,
    required this.repository,
    this.fuelRecord,
  });

  final MotorflowRepository repository;
  final FuelRecord? fuelRecord;

  @override
  State<AddFuelRecordPage> createState() => _AddFuelRecordPageState();
}

class _AddFuelRecordPageState extends State<AddFuelRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _kmAtualController = TextEditingController();
  final _precoLitroController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _litrosController = TextEditingController();
  final _nomePostoController = TextEditingController();
  final _tipoCombustivelController = TextEditingController(text: 'Gasolina');
  final _observacoesController = TextEditingController();
  final _dataController = TextEditingController();

  Vehicle? _selectedVehicle;
  DateTime _data = DateTime.now();
  bool _usarPrecoPadraoGasolina = false;
  bool get _isEditing => widget.fuelRecord != null;

  @override
  void initState() {
    super.initState();
    final vehicles = widget.repository.vehicles;
    final fuelRecord = widget.fuelRecord;
    if (fuelRecord != null) {
      _selectedVehicle = widget.repository.vehicleById(fuelRecord.vehicleId);
      _data = fuelRecord.data;
      _kmAtualController.text = fuelRecord.kmAtual.toString();
      _precoLitroController.text = fuelRecord.precoLitro.toStringAsFixed(2);
      _valorTotalController.text = fuelRecord.valorTotal.toStringAsFixed(2);
      _tipoCombustivelController.text = fuelRecord.tipoCombustivel;
      _nomePostoController.text = fuelRecord.nomePosto;
      _observacoesController.text = fuelRecord.observacoes;
      _litrosController.text = fuelRecord.litros.toStringAsFixed(2);
    } else {
      if (vehicles.isNotEmpty) {
        _selectedVehicle = vehicles.first;
      }
      _precoLitroController.text = widget
          .repository
          .fuelSettings
          .precoPadraoGasolina
          .toStringAsFixed(2);
    }
    _dataController.text = formatDatePtBr(_data);
  }

  @override
  void dispose() {
    _kmAtualController.dispose();
    _precoLitroController.dispose();
    _valorTotalController.dispose();
    _litrosController.dispose();
    _nomePostoController.dispose();
    _tipoCombustivelController.dispose();
    _observacoesController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar abastecimento' : 'Novo abastecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Vehicle>(
                initialValue: _selectedVehicle,
                items: widget.repository.vehicles
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
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Data'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked == null) return;
                  setState(() {
                    _data = picked;
                    _dataController.text = formatDatePtBr(picked);
                  });
                },
              ),
              TextFormField(
                controller: _kmAtualController,
                decoration: const InputDecoration(labelText: 'KM atual'),
                keyboardType: TextInputType.number,
                validator: _intValidator,
              ),
              TextFormField(
                controller: _tipoCombustivelController,
                decoration: const InputDecoration(
                  labelText: 'Tipo combustivel',
                ),
                validator: _requiredValidator,
              ),
              SwitchListTile(
                title: const Text('Usar preco padrao da gasolina'),
                value: _usarPrecoPadraoGasolina,
                onChanged: (value) {
                  setState(() {
                    _usarPrecoPadraoGasolina = value;
                    if (value) {
                      _precoLitroController.text = widget
                          .repository
                          .fuelSettings
                          .precoPadraoGasolina
                          .toStringAsFixed(2);
                      _calcularLitros();
                    }
                  });
                },
              ),
              TextFormField(
                controller: _precoLitroController,
                decoration: const InputDecoration(labelText: 'Preco por litro'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calcularLitros(),
                validator: _doubleValidator,
              ),
              TextFormField(
                controller: _valorTotalController,
                decoration: const InputDecoration(labelText: 'Valor total'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calcularLitros(),
                validator: _doubleValidator,
              ),
              TextFormField(
                controller: _litrosController,
                decoration: const InputDecoration(
                  labelText: 'Litros calculados',
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _nomePostoController,
                decoration: const InputDecoration(labelText: 'Nome do posto'),
                validator: _requiredValidator,
              ),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observacoes'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Salvar alteracoes' : 'Salvar abastecimento',
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
    if (parsed == null || parsed <= 0) {
      return 'Numero invalido';
    }
    return null;
  }

  void _calcularLitros() {
    final preco = double.tryParse(
      _precoLitroController.text.replaceAll(',', '.'),
    );
    final total = double.tryParse(
      _valorTotalController.text.replaceAll(',', '.'),
    );
    if (preco == null || total == null || preco <= 0) {
      _litrosController.text = '';
      return;
    }
    final litros = total / preco;
    _litrosController.text = litros.toStringAsFixed(2);
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _selectedVehicle == null) {
      return;
    }

    if (_isEditing) {
      widget.repository.updateFuelRecord(
        id: widget.fuelRecord!.id,
        vehicleId: _selectedVehicle!.id,
        data: _data,
        kmAtual: int.parse(_kmAtualController.text),
        precoLitro: double.parse(
          _precoLitroController.text.replaceAll(',', '.'),
        ),
        valorTotal: double.parse(
          _valorTotalController.text.replaceAll(',', '.'),
        ),
        nomePosto: _nomePostoController.text.trim(),
        tipoCombustivel: _tipoCombustivelController.text.trim(),
        observacoes: _observacoesController.text.trim(),
      );
    } else {
      widget.repository.addFuelRecord(
        vehicleId: _selectedVehicle!.id,
        data: _data,
        kmAtual: int.parse(_kmAtualController.text),
        precoLitro: double.parse(
          _precoLitroController.text.replaceAll(',', '.'),
        ),
        valorTotal: double.parse(
          _valorTotalController.text.replaceAll(',', '.'),
        ),
        nomePosto: _nomePostoController.text.trim(),
        tipoCombustivel: _tipoCombustivelController.text.trim(),
        observacoes: _observacoesController.text.trim(),
      );
    }

    Navigator.of(context).pop();
  }
}
