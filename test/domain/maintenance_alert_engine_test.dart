import 'package:flutter_test/flutter_test.dart';
import 'package:motorflow/domain/alerts/maintenance_alert.dart';
import 'package:motorflow/domain/alerts/maintenance_alert_engine.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';

void main() {
  group('MaintenanceAlertEngine', () {
    final maintenance = Maintenance(
      id: 'm1',
      vehicleId: 'v1',
      tipo: 'Oleo',
      descricao: 'Troca de oleo',
      kmTroca: 10000,
      dataTroca: DateTime(2026, 1, 1),
      kmProximaTroca: 15000,
      dataProximaTroca: DateTime(2026, 4, 20),
      custo: 200,
    );

    test('retorna overdue por quilometragem', () {
      final vehicle = Vehicle(
        id: 'v1',
        nome: 'Carro',
        modelo: 'Sedan',
        ano: 2023,
        kmAtual: 15000,
      );
      final alert = MaintenanceAlertEngine.evaluate(
        maintenance: maintenance,
        vehicle: vehicle,
        now: DateTime(2026, 4, 1),
      );
      expect(alert.status, MaintenanceAlertStatus.overdue);
    });

    test('retorna dueSoon por quilometragem', () {
      final vehicle = Vehicle(
        id: 'v1',
        nome: 'Carro',
        modelo: 'Sedan',
        ano: 2023,
        kmAtual: 14600,
      );
      final alert = MaintenanceAlertEngine.evaluate(
        maintenance: maintenance,
        vehicle: vehicle,
        now: DateTime(2026, 4, 1),
      );
      expect(alert.status, MaintenanceAlertStatus.dueSoon);
    });

    test('retorna overdue por data', () {
      final vehicle = Vehicle(
        id: 'v1',
        nome: 'Carro',
        modelo: 'Sedan',
        ano: 2023,
        kmAtual: 12000,
      );
      final alert = MaintenanceAlertEngine.evaluate(
        maintenance: maintenance,
        vehicle: vehicle,
        now: DateTime(2026, 4, 30),
      );
      expect(alert.status, MaintenanceAlertStatus.overdue);
    });

    test('retorna onTime quando sem proximidade', () {
      final vehicle = Vehicle(
        id: 'v1',
        nome: 'Carro',
        modelo: 'Sedan',
        ano: 2023,
        kmAtual: 12000,
      );
      final alert = MaintenanceAlertEngine.evaluate(
        maintenance: maintenance,
        vehicle: vehicle,
        now: DateTime(2026, 2, 1),
      );
      expect(alert.status, MaintenanceAlertStatus.onTime);
    });
  });
}
