import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_engine.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_models.dart';

class FuelMetricsCenter {
  const FuelMetricsCenter();

  FuelMetricsSummary buildSummary({
    required List<FuelRecord> records,
    DateTime? now,
  }) {
    return FuelMetricsEngine.buildGlobalSummary(records: records, now: now);
  }

  List<FuelRecordInsight> buildRecordInsights({
    required List<FuelRecord> records,
  }) {
    return FuelMetricsEngine.buildRecordInsights(records: records);
  }

  List<VehicleFuelMonthlySummary> buildVehicleMonthlySummaries({
    required List<FuelRecord> records,
    DateTime? now,
  }) {
    return FuelMetricsEngine.buildVehicleMonthlySummaries(
      records: records,
      now: now,
    );
  }

  List<VehicleFuelRollup> buildVehicleFuelRollups({
    required List<FuelRecord> records,
  }) {
    return FuelMetricsEngine.buildVehicleFuelRollups(records: records);
  }
}
