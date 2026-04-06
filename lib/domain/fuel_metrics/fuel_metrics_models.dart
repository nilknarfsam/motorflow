class FuelRecordInsight {
  const FuelRecordInsight({
    required this.recordId,
    required this.vehicleId,
    required this.distanceKm,
    required this.consumptionKmPerLiter,
    required this.costPerKm,
  });

  final String recordId;
  final String vehicleId;
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
  });

  final String vehicleId;
  final double totalSpentMonth;
  final double totalLitersMonth;
  final double averagePricePerLiterMonth;
}

class FuelMetricsSummary {
  const FuelMetricsSummary({
    required this.averageConsumptionKmPerLiter,
    required this.averageCostPerKm,
    required this.totalSpentMonth,
    required this.totalLitersMonth,
    required this.averagePricePerLiterMonth,
  });

  final double? averageConsumptionKmPerLiter;
  final double? averageCostPerKm;
  final double totalSpentMonth;
  final double totalLitersMonth;
  final double? averagePricePerLiterMonth;
}
