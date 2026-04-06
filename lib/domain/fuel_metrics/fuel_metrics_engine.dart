import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_models.dart';

class FuelMetricsEngine {
  const FuelMetricsEngine._();

  static List<FuelRecordInsight> buildRecordInsights({
    required List<FuelRecord> records,
  }) {
    final byVehicle = <String, List<FuelRecord>>{};
    for (final record in records) {
      byVehicle.putIfAbsent(record.vehicleId, () => []).add(record);
    }

    final insights = <FuelRecordInsight>[];
    for (final vehicleRecords in byVehicle.values) {
      final ordered = List<FuelRecord>.from(vehicleRecords)
        ..sort((a, b) {
          final kmCompare = a.kmAtual.compareTo(b.kmAtual);
          if (kmCompare != 0) {
            return kmCompare;
          }
          return a.data.compareTo(b.data);
        });

      for (var i = 1; i < ordered.length; i++) {
        final previous = ordered[i - 1];
        final current = ordered[i];
        final distance = current.kmAtual - previous.kmAtual;
        if (distance <= 0 || current.litros <= 0) {
          continue;
        }
        insights.add(
          FuelRecordInsight(
            recordId: current.id,
            vehicleId: current.vehicleId,
            distanceKm: distance,
            consumptionKmPerLiter: distance / current.litros,
            costPerKm: current.valorTotal / distance,
          ),
        );
      }
    }
    return insights;
  }

  static FuelMetricsSummary buildGlobalSummary({
    required List<FuelRecord> records,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final monthRecords = records
        .where(
          (record) =>
              record.data.year == currentDate.year &&
              record.data.month == currentDate.month,
        )
        .toList();

    final totalSpentMonth = monthRecords.fold<double>(
      0,
      (sum, record) => sum + record.valorTotal,
    );
    final totalLitersMonth = monthRecords.fold<double>(
      0,
      (sum, record) => sum + record.litros,
    );
    final averagePricePerLiterMonth = totalLitersMonth > 0
        ? totalSpentMonth / totalLitersMonth
        : null;

    final insights = buildRecordInsights(records: records);
    final totalDistance = insights.fold<int>(
      0,
      (sum, insight) => sum + insight.distanceKm,
    );
    final totalLitersFromInsights = insights.fold<double>(
      0,
      (sum, insight) =>
          sum + (insight.distanceKm / insight.consumptionKmPerLiter),
    );
    final totalCostFromInsights = insights.fold<double>(
      0,
      (sum, insight) => sum + (insight.costPerKm * insight.distanceKm),
    );

    final avgConsumption = (totalDistance > 0 && totalLitersFromInsights > 0)
        ? totalDistance / totalLitersFromInsights
        : null;
    final avgCostPerKm = totalDistance > 0
        ? totalCostFromInsights / totalDistance
        : null;

    return FuelMetricsSummary(
      averageConsumptionKmPerLiter: avgConsumption,
      averageCostPerKm: avgCostPerKm,
      totalSpentMonth: totalSpentMonth,
      totalLitersMonth: totalLitersMonth,
      averagePricePerLiterMonth: averagePricePerLiterMonth,
    );
  }

  static List<VehicleFuelMonthlySummary> buildVehicleMonthlySummaries({
    required List<FuelRecord> records,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final byVehicle = <String, List<FuelRecord>>{};
    for (final record in records) {
      if (record.data.year != currentDate.year ||
          record.data.month != currentDate.month) {
        continue;
      }
      byVehicle.putIfAbsent(record.vehicleId, () => []).add(record);
    }

    return byVehicle.entries.map((entry) {
      final vehicleRecords = entry.value;
      final spent = vehicleRecords.fold<double>(
        0,
        (sum, record) => sum + record.valorTotal,
      );
      final liters = vehicleRecords.fold<double>(
        0,
        (sum, record) => sum + record.litros,
      );
      return VehicleFuelMonthlySummary(
        vehicleId: entry.key,
        totalSpentMonth: spent,
        totalLitersMonth: liters,
        averagePricePerLiterMonth: liters > 0 ? spent / liters : 0,
      );
    }).toList()..sort((a, b) => b.totalSpentMonth.compareTo(a.totalSpentMonth));
  }
}
