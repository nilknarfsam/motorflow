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
            refuelDate: current.data,
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

    final allInsights = buildRecordInsights(records: records);
    final insightsInMonth = allInsights.where((i) {
      final d = i.refuelDate;
      return d.year == currentDate.year && d.month == currentDate.month;
    }).toList();

    final agg = _aggregatePairInsights(insightsInMonth);

    return FuelMetricsSummary(
      averageConsumptionKmPerLiter: agg.avgConsumption,
      averageCostPerKm: agg.avgCost,
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

    final allInsights = buildRecordInsights(records: records);
    final insightsInMonth = allInsights.where((i) {
      final d = i.refuelDate;
      return d.year == currentDate.year && d.month == currentDate.month;
    }).toList();

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
      final vehicleInsights = insightsInMonth
          .where((i) => i.vehicleId == entry.key)
          .toList();
      final agg = _aggregatePairInsights(vehicleInsights);
      return VehicleFuelMonthlySummary(
        vehicleId: entry.key,
        totalSpentMonth: spent,
        totalLitersMonth: liters,
        averagePricePerLiterMonth: liters > 0 ? spent / liters : 0,
        averageConsumptionKmPerLiter: agg.avgConsumption,
        averageCostPerKm: agg.avgCost,
      );
    }).toList()..sort((a, b) => b.totalSpentMonth.compareTo(a.totalSpentMonth));
  }

  static List<VehicleFuelRollup> buildVehicleFuelRollups({
    required List<FuelRecord> records,
  }) {
    final allInsights = buildRecordInsights(records: records);
    final byVehicle = <String, List<FuelRecordInsight>>{};
    for (final insight in allInsights) {
      byVehicle.putIfAbsent(insight.vehicleId, () => []).add(insight);
    }
    final rollups = byVehicle.entries.map((entry) {
      final agg = _aggregatePairInsights(entry.value);
      return VehicleFuelRollup(
        vehicleId: entry.key,
        validPairCount: entry.value.length,
        averageConsumptionKmPerLiter: agg.avgConsumption,
        averageCostPerKm: agg.avgCost,
      );
    }).toList();
    rollups.sort((a, b) => a.vehicleId.compareTo(b.vehicleId));
    return rollups;
  }

  static ({double? avgConsumption, double? avgCost}) _aggregatePairInsights(
    List<FuelRecordInsight> insights,
  ) {
    if (insights.isEmpty) {
      return (avgConsumption: null, avgCost: null);
    }
    var totalDist = 0;
    var totalLiters = 0.0;
    var totalCostWeighted = 0.0;
    for (final i in insights) {
      totalDist += i.distanceKm;
      totalLiters += i.distanceKm / i.consumptionKmPerLiter;
      totalCostWeighted += i.costPerKm * i.distanceKm;
    }
    final avgConsumption = totalLiters > 0 ? totalDist / totalLiters : null;
    final avgCost = totalDist > 0 ? totalCostWeighted / totalDist : null;
    return (avgConsumption: avgConsumption, avgCost: avgCost);
  }
}
