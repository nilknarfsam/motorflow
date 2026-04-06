import 'dart:async';

import 'package:motorflow/data/local/memory_motorflow_local_store.dart';
import 'package:motorflow/data/local/motorflow_local_store.dart';
import 'package:motorflow/data/models/motorflow_snapshot.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/fuel_settings.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';

class InMemoryMotorflowRepository extends MotorflowRepository {
  InMemoryMotorflowRepository._(this._localStore);

  static Future<InMemoryMotorflowRepository> create({
    MotorflowLocalStore? localStore,
  }) async {
    final repository = InMemoryMotorflowRepository._(
      localStore ?? MemoryMotorflowLocalStore(),
    );
    await repository._hydrateFromSnapshot();
    return repository;
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
    _saveSnapshot();
    notifyListeners();
  }

  @override
  void updateVehicle({
    required String id,
    required String nome,
    required String modelo,
    required int ano,
    required int kmAtual,
  }) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == id);
    if (index == -1) {
      return;
    }
    _vehicles[index] = Vehicle(
      id: id,
      nome: nome,
      modelo: modelo,
      ano: ano,
      kmAtual: kmAtual,
    );
    _saveSnapshot();
    notifyListeners();
  }

  @override
  void deleteVehicle(String id) {
    final initialLength = _vehicles.length;
    _vehicles.removeWhere((vehicle) => vehicle.id == id);
    final hasRemoved = _vehicles.length < initialLength;
    if (!hasRemoved) {
      return;
    }
    _maintenances.removeWhere((maintenance) => maintenance.vehicleId == id);
    _fuelRecords.removeWhere((fuelRecord) => fuelRecord.vehicleId == id);
    _saveSnapshot();
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
    _saveSnapshot();
    notifyListeners();
  }

  @override
  void updateMaintenance({
    required String id,
    required String vehicleId,
    required String tipo,
    required String descricao,
    required int kmTroca,
    required DateTime dataTroca,
    required int kmProximaTroca,
    required DateTime dataProximaTroca,
    required double custo,
  }) {
    final index = _maintenances.indexWhere(
      (maintenance) => maintenance.id == id,
    );
    if (index == -1) {
      return;
    }
    _maintenances[index] = Maintenance(
      id: id,
      vehicleId: vehicleId,
      tipo: tipo,
      descricao: descricao,
      kmTroca: kmTroca,
      dataTroca: dataTroca,
      kmProximaTroca: kmProximaTroca,
      dataProximaTroca: dataProximaTroca,
      custo: custo,
    );
    _saveSnapshot();
    notifyListeners();
  }

  @override
  void deleteMaintenance(String id) {
    final initialLength = _maintenances.length;
    _maintenances.removeWhere((maintenance) => maintenance.id == id);
    final hasRemoved = _maintenances.length < initialLength;
    if (!hasRemoved) {
      return;
    }
    _saveSnapshot();
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
    _saveSnapshot();
    notifyListeners();
  }

  @override
  void updateFuelRecord({
    required String id,
    required String vehicleId,
    required DateTime data,
    required int kmAtual,
    required double precoLitro,
    required double valorTotal,
    required String nomePosto,
    required String tipoCombustivel,
    required String observacoes,
  }) {
    final index = _fuelRecords.indexWhere((fuelRecord) => fuelRecord.id == id);
    if (index == -1) {
      return;
    }
    _fuelRecords[index] = FuelRecord(
      id: id,
      vehicleId: vehicleId,
      data: data,
      kmAtual: kmAtual,
      precoLitro: precoLitro,
      valorTotal: valorTotal,
      litros: valorTotal / precoLitro,
      nomePosto: nomePosto,
      tipoCombustivel: tipoCombustivel,
      observacoes: observacoes,
    );
    _saveSnapshot();
    notifyListeners();
  }

  @override
  void deleteFuelRecord(String id) {
    final initialLength = _fuelRecords.length;
    _fuelRecords.removeWhere((fuelRecord) => fuelRecord.id == id);
    final hasRemoved = _fuelRecords.length < initialLength;
    if (!hasRemoved) {
      return;
    }
    _saveSnapshot();
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
    _saveSnapshot();
    notifyListeners();
  }

  Future<void> _hydrateFromSnapshot() async {
    try {
      final snapshot = await _localStore.readSnapshot();
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
    } catch (_) {
      // Fail-safe: keep valid empty in-memory state.
    }
  }

  void _saveSnapshot() {
    final snapshot = MotorflowSnapshot(
      vehicles: List<Vehicle>.from(_vehicles),
      maintenances: List<Maintenance>.from(_maintenances),
      fuelRecords: List<FuelRecord>.from(_fuelRecords),
      fuelSettings: _fuelSettings,
      vehicleCounter: _vehicleCounter,
      maintenanceCounter: _maintenanceCounter,
      fuelCounter: _fuelCounter,
    );
    unawaited(_writeSnapshot(snapshot));
  }

  Future<void> _writeSnapshot(MotorflowSnapshot snapshot) async {
    try {
      await _localStore.writeSnapshot(snapshot);
    } catch (_) {
      // Fail-safe: write failures should not interrupt user flow.
    }
  }
}
