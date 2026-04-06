import 'package:motorflow/domain/alerts/maintenance_alert.dart';
import 'package:motorflow/domain/entities/maintenance.dart';
import 'package:motorflow/domain/entities/vehicle.dart';

class MaintenanceAlertEngine {
  const MaintenanceAlertEngine._();

  static const int dueSoonKmThreshold = 500;
  static const int dueSoonDaysThreshold = 7;

  static MaintenanceAlert evaluate({
    required Maintenance maintenance,
    required Vehicle? vehicle,
    DateTime? now,
  }) {
    final currentDate = DateTime(
      (now ?? DateTime.now()).year,
      (now ?? DateTime.now()).month,
      (now ?? DateTime.now()).day,
    );

    if (vehicle == null) {
      return MaintenanceAlert(
        maintenanceId: maintenance.id,
        vehicleId: maintenance.vehicleId,
        status: MaintenanceAlertStatus.neutral,
        reasons: const ['Sem dados do veiculo'],
      );
    }

    var status = MaintenanceAlertStatus.onTime;
    final reasons = <String>[];

    final kmRemaining = maintenance.kmProximaTroca - vehicle.kmAtual;
    if (vehicle.kmAtual >= maintenance.kmProximaTroca) {
      status = _maxStatus(status, MaintenanceAlertStatus.overdue);
      reasons.add('Vencida por km');
    } else if (kmRemaining <= dueSoonKmThreshold) {
      status = _maxStatus(status, MaintenanceAlertStatus.dueSoon);
      reasons.add('Proxima por km');
    }

    final dueDate = DateTime(
      maintenance.dataProximaTroca.year,
      maintenance.dataProximaTroca.month,
      maintenance.dataProximaTroca.day,
    );
    final dayDiff = dueDate.difference(currentDate).inDays;
    if (currentDate.isAfter(dueDate)) {
      status = _maxStatus(status, MaintenanceAlertStatus.overdue);
      reasons.add('Vencida por data');
    } else if (dayDiff <= dueSoonDaysThreshold) {
      status = _maxStatus(status, MaintenanceAlertStatus.dueSoon);
      reasons.add('Proxima por data');
    }

    if (reasons.isEmpty) {
      reasons.add('Em dia');
    }

    return MaintenanceAlert(
      maintenanceId: maintenance.id,
      vehicleId: maintenance.vehicleId,
      status: status,
      reasons: reasons,
    );
  }

  static List<MaintenanceAlert> evaluateAll({
    required List<Maintenance> maintenances,
    required List<Vehicle> vehicles,
    DateTime? now,
  }) {
    final vehicleById = {for (final vehicle in vehicles) vehicle.id: vehicle};
    return maintenances
        .map(
          (maintenance) => evaluate(
            maintenance: maintenance,
            vehicle: vehicleById[maintenance.vehicleId],
            now: now,
          ),
        )
        .toList();
  }

  static MaintenanceAlertStatus _maxStatus(
    MaintenanceAlertStatus left,
    MaintenanceAlertStatus right,
  ) {
    return _severity(left) >= _severity(right) ? left : right;
  }

  static int _severity(MaintenanceAlertStatus status) {
    switch (status) {
      case MaintenanceAlertStatus.neutral:
        return 0;
      case MaintenanceAlertStatus.onTime:
        return 1;
      case MaintenanceAlertStatus.dueSoon:
        return 2;
      case MaintenanceAlertStatus.overdue:
        return 3;
    }
  }
}
