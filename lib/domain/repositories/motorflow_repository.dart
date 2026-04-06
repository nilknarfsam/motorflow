import 'package:flutter/foundation.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/fuel_settings.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';

abstract class MotorflowRepository extends ChangeNotifier {
  List<Vehicle> get vehicles;
  List<Maintenance> get maintenances;
  List<FuelRecord> get fuelRecords;
  FuelSettings get fuelSettings;

  Vehicle? vehicleById(String vehicleId);
  List<Maintenance> maintenancesByVehicle(String vehicleId);
  List<FuelRecord> fuelRecordsByVehicle(String vehicleId);

  void addVehicle({
    required String nome,
    required String modelo,
    required int ano,
    required int kmAtual,
  });
  void updateVehicle({
    required String id,
    required String nome,
    required String modelo,
    required int ano,
    required int kmAtual,
  });
  void deleteVehicle(String id);

  void addMaintenance({
    required String vehicleId,
    required String tipo,
    required String descricao,
    required int kmTroca,
    required DateTime dataTroca,
    required int kmProximaTroca,
    required DateTime dataProximaTroca,
    required double custo,
  });
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
  });
  void deleteMaintenance(String id);

  void addFuelRecord({
    required String vehicleId,
    required DateTime data,
    required int kmAtual,
    required double precoLitro,
    required double valorTotal,
    required String nomePosto,
    required String tipoCombustivel,
    required String observacoes,
  });
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
  });
  void deleteFuelRecord(String id);

  void updateFuelSettings({
    double? precoPadraoGasolina,
    double? precoPadraoEtanol,
    double? precoPadraoDiesel,
  });
}
