import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/fuel_settings.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class InMemoryMotorflowRepository extends MotorflowRepository {
  final List<Vehicle> _vehicles = <Vehicle>[];
  final List<Maintenance> _maintenances = <Maintenance>[];
  final List<FuelRecord> _fuelRecords = <FuelRecord>[];

  FuelSettings _fuelSettings = const FuelSettings(
    precoPadraoGasolina: 5.79,
    precoPadraoEtanol: 3.99,
    precoPadraoDiesel: 6.19,
  );

  int _vehicleCounter = 0;
  int _maintenanceCounter = 0;
  int _fuelCounter = 0;

  @override
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  @override
  List<Maintenance> get maintenances => List.unmodifiable(_maintenances);

  @override
  List<FuelRecord> get fuelRecords => List.unmodifiable(_fuelRecords);

  @override
  FuelSettings get fuelSettings => _fuelSettings;

  @override
  Vehicle? vehicleById(String vehicleId) {
    for (final vehicle in _vehicles) {
      if (vehicle.id == vehicleId) {
        return vehicle;
      }
    }
    return null;
  }

  @override
  List<Maintenance> maintenancesByVehicle(String vehicleId) {
    return _maintenances.where((m) => m.vehicleId == vehicleId).toList();
  }

  @override
  List<FuelRecord> fuelRecordsByVehicle(String vehicleId) {
    return _fuelRecords.where((f) => f.vehicleId == vehicleId).toList();
  }

  @override
  void addVehicle({
    required String nome,
    required String modelo,
    required int ano,
    required int kmAtual,
  }) {
    _vehicleCounter += 1;
    _vehicles.add(
      Vehicle(
        id: 'v$_vehicleCounter',
        nome: nome,
        modelo: modelo,
        ano: ano,
        kmAtual: kmAtual,
      ),
    );
    notifyListeners();
  }

  @override
  void addMaintenance({
    required String vehicleId,
    required String tipo,
    required String descricao,
    required int kmTroca,
    required DateTime dataTroca,
    required int kmProximaTroca,
    required DateTime dataProximaTroca,
    required double custo,
  }) {
    _maintenanceCounter += 1;
    _maintenances.add(
      Maintenance(
        id: 'm$_maintenanceCounter',
        vehicleId: vehicleId,
        tipo: tipo,
        descricao: descricao,
        kmTroca: kmTroca,
        dataTroca: dataTroca,
        kmProximaTroca: kmProximaTroca,
        dataProximaTroca: dataProximaTroca,
        custo: custo,
      ),
    );
    notifyListeners();
  }

  @override
  void addFuelRecord({
    required String vehicleId,
    required DateTime data,
    required int kmAtual,
    required double precoLitro,
    required double valorTotal,
    required String nomePosto,
    required String tipoCombustivel,
    required String observacoes,
  }) {
    _fuelCounter += 1;
    final litros = valorTotal / precoLitro;
    _fuelRecords.add(
      FuelRecord(
        id: 'f$_fuelCounter',
        vehicleId: vehicleId,
        data: data,
        kmAtual: kmAtual,
        precoLitro: precoLitro,
        valorTotal: valorTotal,
        litros: litros,
        nomePosto: nomePosto,
        tipoCombustivel: tipoCombustivel,
        observacoes: observacoes,
      ),
    );
    notifyListeners();
  }

  @override
  void updateFuelSettings({
    double? precoPadraoGasolina,
    double? precoPadraoEtanol,
    double? precoPadraoDiesel,
  }) {
    _fuelSettings = _fuelSettings.copyWith(
      precoPadraoGasolina: precoPadraoGasolina,
      precoPadraoEtanol: precoPadraoEtanol,
      precoPadraoDiesel: precoPadraoDiesel,
    );
    notifyListeners();
  }
}
