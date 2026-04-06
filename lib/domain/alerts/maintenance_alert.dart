enum MaintenanceAlertStatus { neutral, onTime, dueSoon, overdue }

class MaintenanceAlert {
  const MaintenanceAlert({
    required this.maintenanceId,
    required this.vehicleId,
    required this.status,
    required this.reasons,
  });

  final String maintenanceId;
  final String vehicleId;
  final MaintenanceAlertStatus status;
  final List<String> reasons;

  bool get isAlert =>
      status == MaintenanceAlertStatus.dueSoon ||
      status == MaintenanceAlertStatus.overdue;
}
