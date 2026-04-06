import 'package:motorflow/domain/alerts/maintenance_alert.dart';
import 'package:motorflow/domain/alerts/maintenance_alert_engine.dart';
import 'package:motorflow/domain/alerts/maintenance_alert_summary.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';

class MaintenanceAlertCenter {
  const MaintenanceAlertCenter();

  List<MaintenanceAlert> buildAlerts({
    required List<Maintenance> maintenances,
    required List<Vehicle> vehicles,
    DateTime? now,
  }) {
    return MaintenanceAlertEngine.evaluateAll(
      maintenances: maintenances,
      vehicles: vehicles,
      now: now,
    );
  }

  MaintenanceAlertSummary buildSummary({
    required List<Maintenance> maintenances,
    required List<Vehicle> vehicles,
    DateTime? now,
  }) {
    final alerts = buildAlerts(
      maintenances: maintenances,
      vehicles: vehicles,
      now: now,
    );
    return MaintenanceAlertSummary.fromAlerts(alerts);
  }
}
