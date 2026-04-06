class FuelRecordInsight {
  const FuelRecordInsight({
    required this.recordId,
    required this.vehicleId,
    required this.refuelDate,
    required this.distanceKm,
    required this.consumptionKmPerLiter,
    required this.costPerKm,
  });

  final String recordId;
  final String vehicleId;

  /// Data do abastecimento atual (segundo par), usada para filtrar por período.
  final DateTime refuelDate;

  final int distanceKm;
  final double consumptionKmPerLiter;
  final double costPerKm;
}

class VehicleFuelMonthlySummary {
  const VehicleFuelMonthlySummary({
    required this.vehicleId,
    required this.totalSpentMonth,
    required this.totalLitersMonth,
    required this.averagePricePerLiterMonth,
    this.averageConsumptionKmPerLiter,
    this.averageCostPerKm,
  });

  final String vehicleId;
  final double totalSpentMonth;
  final double totalLitersMonth;
  final double averagePricePerLiterMonth;

  /// Média ponderada a partir de intervalos válidos no mês (pares consecutivos).
  final double? averageConsumptionKmPerLiter;

  /// Média ponderada a partir de intervalos válidos no mês (pares consecutivos).
  final double? averageCostPerKm;
}

/// Indicadores derivados de todos os intervalos válidos do veículo (histórico).
class VehicleFuelRollup {
  const VehicleFuelRollup({
    required this.vehicleId,
    required this.validPairCount,
    this.averageConsumptionKmPerLiter,
    this.averageCostPerKm,
  });

  final String vehicleId;
  final int validPairCount;
  final double? averageConsumptionKmPerLiter;
  final double? averageCostPerKm;
}

class FuelMetricsSummary {
  const FuelMetricsSummary({
    required this.averageConsumptionKmPerLiter,
    required this.averageCostPerKm,
    required this.totalSpentMonth,
    required this.totalLitersMonth,
    required this.averagePricePerLiterMonth,
  });

  /// Média da frota no mês atual, apenas com intervalos cujo abastecimento atual cai no mês.
  final double? averageConsumptionKmPerLiter;
  final double? averageCostPerKm;
  final double totalSpentMonth;
  final double totalLitersMonth;
  final double? averagePricePerLiterMonth;
}
