import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/fuel_settings.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';

class MotorflowSnapshot {
  const MotorflowSnapshot({
    required this.vehicles,
    required this.maintenances,
    required this.fuelRecords,
    required this.fuelSettings,
    required this.vehicleCounter,
    required this.maintenanceCounter,
    required this.fuelCounter,
  });

  final List<Vehicle> vehicles;
  final List<Maintenance> maintenances;
  final List<FuelRecord> fuelRecords;
  final FuelSettings fuelSettings;
  final int vehicleCounter;
  final int maintenanceCounter;
  final int fuelCounter;

  Map<String, Object?> toMap() {
    return {
      'vehicleCounter': vehicleCounter,
      'maintenanceCounter': maintenanceCounter,
      'fuelCounter': fuelCounter,
      'fuelSettings': {
        'precoPadraoGasolina': fuelSettings.precoPadraoGasolina,
        'precoPadraoEtanol': fuelSettings.precoPadraoEtanol,
        'precoPadraoDiesel': fuelSettings.precoPadraoDiesel,
      },
      'vehicles': vehicles
          .map(
            (v) => {
              'id': v.id,
              'nome': v.nome,
              'modelo': v.modelo,
              'ano': v.ano,
              'kmAtual': v.kmAtual,
            },
          )
          .toList(),
      'maintenances': maintenances
          .map(
            (m) => {
              'id': m.id,
              'vehicleId': m.vehicleId,
              'tipo': m.tipo,
              'descricao': m.descricao,
              'kmTroca': m.kmTroca,
              'dataTroca': m.dataTroca.toIso8601String(),
              'kmProximaTroca': m.kmProximaTroca,
              'dataProximaTroca': m.dataProximaTroca.toIso8601String(),
              'custo': m.custo,
            },
          )
          .toList(),
      'fuelRecords': fuelRecords
          .map(
            (f) => {
              'id': f.id,
              'vehicleId': f.vehicleId,
              'data': f.data.toIso8601String(),
              'kmAtual': f.kmAtual,
              'precoLitro': f.precoLitro,
              'valorTotal': f.valorTotal,
              'litros': f.litros,
              'nomePosto': f.nomePosto,
              'tipoCombustivel': f.tipoCombustivel,
              'observacoes': f.observacoes,
            },
          )
          .toList(),
    };
  }
}
