import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/entities/fuel_settings.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';

class MotorflowSnapshot {
  static const int schemaVersion = 1;
  static const int primaryKey = 1;

  const MotorflowSnapshot({
    required this.vehicles,
    required this.maintenances,
    required this.fuelRecords,
    required this.fuelSettings,
    required this.vehicleCounter,
    required this.maintenanceCounter,
    required this.fuelCounter,
    this.snapshotSchemaVersion = schemaVersion,
  });

  final List<Vehicle> vehicles;
  final List<Maintenance> maintenances;
  final List<FuelRecord> fuelRecords;
  final FuelSettings fuelSettings;
  final int vehicleCounter;
  final int maintenanceCounter;
  final int fuelCounter;
  final int snapshotSchemaVersion;

  Map<String, Object?> toMap() {
    return {
      'vehicleCounter': vehicleCounter,
      'maintenanceCounter': maintenanceCounter,
      'fuelCounter': fuelCounter,
      'schemaVersion': snapshotSchemaVersion,
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

  static MotorflowSnapshot? fromMap(Map<String, Object?>? raw) {
    if (raw == null) {
      return null;
    }
    try {
      final fuelMap = raw['fuelSettings'] as Map<Object?, Object?>?;
      final vehiclesList = (raw['vehicles'] as List<Object?>? ?? const [])
          .cast<Map<Object?, Object?>>();
      final maintenancesList =
          (raw['maintenances'] as List<Object?>? ?? const [])
              .cast<Map<Object?, Object?>>();
      final fuelRecordsList = (raw['fuelRecords'] as List<Object?>? ?? const [])
          .cast<Map<Object?, Object?>>();

      return MotorflowSnapshot(
        vehicles: vehiclesList
            .map(
              (v) => Vehicle(
                id: _readString(v['id'], ''),
                nome: _readString(v['nome'], ''),
                modelo: _readString(v['modelo'], ''),
                ano: _readInt(v['ano'], 0),
                kmAtual: _readInt(v['kmAtual'], 0),
              ),
            )
            .where((v) => v.id.isNotEmpty)
            .toList(),
        maintenances: maintenancesList
            .map(
              (m) => Maintenance(
                id: _readString(m['id'], ''),
                vehicleId: _readString(m['vehicleId'], ''),
                tipo: _readString(m['tipo'], ''),
                descricao: _readString(m['descricao'], ''),
                kmTroca: _readInt(m['kmTroca'], 0),
                dataTroca: _readDate(m['dataTroca']),
                kmProximaTroca: _readInt(m['kmProximaTroca'], 0),
                dataProximaTroca: _readDate(m['dataProximaTroca']),
                custo: _readDouble(m['custo'], 0),
              ),
            )
            .where((m) => m.id.isNotEmpty && m.vehicleId.isNotEmpty)
            .toList(),
        fuelRecords: fuelRecordsList
            .map(
              (f) => FuelRecord(
                id: _readString(f['id'], ''),
                vehicleId: _readString(f['vehicleId'], ''),
                data: _readDate(f['data']),
                kmAtual: _readInt(f['kmAtual'], 0),
                precoLitro: _readDouble(f['precoLitro'], 0),
                valorTotal: _readDouble(f['valorTotal'], 0),
                litros: _readDouble(f['litros'], 0),
                nomePosto: _readString(f['nomePosto'], ''),
                tipoCombustivel: _readString(f['tipoCombustivel'], ''),
                observacoes: _readString(f['observacoes'], ''),
              ),
            )
            .where((f) => f.id.isNotEmpty && f.vehicleId.isNotEmpty)
            .toList(),
        fuelSettings: FuelSettings(
          precoPadraoGasolina: _readDouble(
            fuelMap?['precoPadraoGasolina'],
            5.79,
          ),
          precoPadraoEtanol: _readDouble(fuelMap?['precoPadraoEtanol'], 3.99),
          precoPadraoDiesel: _readDouble(fuelMap?['precoPadraoDiesel'], 6.19),
        ),
        vehicleCounter: _readInt(raw['vehicleCounter'], 0),
        maintenanceCounter: _readInt(raw['maintenanceCounter'], 0),
        fuelCounter: _readInt(raw['fuelCounter'], 0),
        snapshotSchemaVersion: _readInt(raw['schemaVersion'], schemaVersion),
      );
    } catch (_) {
      return null;
    }
  }

  static String _readString(Object? value, String fallback) {
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static int _readInt(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static double _readDouble(Object? value, double fallback) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static DateTime _readDate(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
