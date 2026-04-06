import 'package:motorflow/data/local/memory_motorflow_local_store.dart';
import 'package:motorflow/data/local/motorflow_local_store.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/fuel_settings.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class InMemoryMotorflowRepository extends MotorflowRepository {
  InMemoryMotorflowRepository({MotorflowLocalStore? localStore})
    : _localStore = localStore ?? MemoryMotorflowLocalStore() {
    _hydrateFromSnapshot();
  }

  final MotorflowLocalStore _localStore;
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
    _persistSnapshot();
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
    _persistSnapshot();
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
    _persistSnapshot();
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
    _persistSnapshot();
    notifyListeners();
  }

  void _hydrateFromSnapshot() {
    final snapshot = _localStore.readSnapshot();
    if (snapshot == null) {
      return;
    }
    _vehicles
      ..clear()
      ..addAll(snapshot.vehicles);
    _maintenances
      ..clear()
      ..addAll(snapshot.maintenances);
    _fuelRecords
      ..clear()
      ..addAll(snapshot.fuelRecords);
    _fuelSettings = snapshot.fuelSettings;
    _vehicleCounter = snapshot.vehicleCounter;
    _maintenanceCounter = snapshot.maintenanceCounter;
    _fuelCounter = snapshot.fuelCounter;
  }

  void _persistSnapshot() {
    final snapshot = MotorflowSnapshot(
      vehicles: List<Vehicle>.from(_vehicles),
      maintenances: List<Maintenance>.from(_maintenances),
      fuelRecords: List<FuelRecord>.from(_fuelRecords),
      fuelSettings: _fuelSettings,
      vehicleCounter: _vehicleCounter,
      maintenanceCounter: _maintenanceCounter,
      fuelCounter: _fuelCounter,
    );
    _localStore.writeSnapshot(snapshot);
  }
}
