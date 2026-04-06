import 'package:motorflow/domain/alerts/maintenance_alert.dart';

class MaintenanceAlertSummary {
  const MaintenanceAlertSummary({
    required this.total,
    required this.overdue,
    required this.dueSoon,
    required this.onTime,
    required this.neutral,
  });

  final int total;
  final int overdue;
  final int dueSoon;
  final int onTime;
  final int neutral;

  int get totalAlerts => overdue + dueSoon;

  static MaintenanceAlertSummary fromAlerts(List<MaintenanceAlert> alerts) {
    var overdue = 0;
    var dueSoon = 0;
    var onTime = 0;
    var neutral = 0;
    for (final alert in alerts) {
      switch (alert.status) {
        case MaintenanceAlertStatus.overdue:
          overdue += 1;
          break;
        case MaintenanceAlertStatus.dueSoon:
          dueSoon += 1;
          break;
        case MaintenanceAlertStatus.onTime:
          onTime += 1;
          break;
        case MaintenanceAlertStatus.neutral:
          neutral += 1;
          break;
      }
    }
    return MaintenanceAlertSummary(
      total: alerts.length,
      overdue: overdue,
      dueSoon: dueSoon,
      onTime: onTime,
      neutral: neutral,
    );
  }
}
