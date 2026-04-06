import 'package:flutter_test/flutter_test.dart';
import 'package:motorflow/domain/entities/fuel_record.dart';
import 'package:motorflow/domain/fuel_metrics/fuel_metrics_engine.dart';

void main() {
  group('FuelMetricsEngine', () {
    final records = [
      FuelRecord(
        id: 'f1',
        vehicleId: 'v1',
        data: DateTime(2026, 4, 2),
        kmAtual: 10000,
        precoLitro: 5.5,
        valorTotal: 220,
        litros: 40,
        nomePosto: 'A',
        tipoCombustivel: 'Gasolina',
        observacoes: '',
      ),
      FuelRecord(
        id: 'f2',
        vehicleId: 'v1',
        data: DateTime(2026, 4, 15),
        kmAtual: 10400,
        precoLitro: 5.6,
        valorTotal: 224,
        litros: 40,
        nomePosto: 'B',
        tipoCombustivel: 'Gasolina',
        observacoes: '',
      ),
      FuelRecord(
        id: 'f3',
        vehicleId: 'v2',
        data: DateTime(2026, 4, 20),
        kmAtual: 5000,
        precoLitro: 6.0,
        valorTotal: 180,
        litros: 30,
        nomePosto: 'C',
        tipoCombustivel: 'Diesel',
        observacoes: '',
      ),
    ];

    test('calcula insights por pares consecutivos validos', () {
      final insights = FuelMetricsEngine.buildRecordInsights(records: records);
      expect(insights.length, 1);
      expect(insights.first.recordId, 'f2');
      expect(insights.first.distanceKm, 400);
      expect(insights.first.consumptionKmPerLiter, closeTo(10, 0.001));
      expect(insights.first.costPerKm, closeTo(0.56, 0.001));
    });

    test('calcula resumo global e metricas mensais', () {
      final summary = FuelMetricsEngine.buildGlobalSummary(
        records: records,
        now: DateTime(2026, 4, 25),
      );
      expect(summary.totalSpentMonth, closeTo(624, 0.001));
      expect(summary.totalLitersMonth, closeTo(110, 0.001));
      expect(summary.averagePricePerLiterMonth, closeTo(5.6727, 0.01));
      expect(summary.averageConsumptionKmPerLiter, closeTo(10, 0.001));
      expect(summary.averageCostPerKm, closeTo(0.56, 0.001));
    });

    test('retorna neutro quando dados insuficientes', () {
      final summary = FuelMetricsEngine.buildGlobalSummary(
        records: [records.first],
        now: DateTime(2026, 4, 25),
      );
      expect(summary.averageConsumptionKmPerLiter, isNull);
      expect(summary.averageCostPerKm, isNull);
    });

    test('agrega métricas por veículo no histórico', () {
      final rollups = FuelMetricsEngine.buildVehicleFuelRollups(records: records);
      expect(rollups.length, 1);
      expect(rollups.single.vehicleId, 'v1');
      expect(rollups.single.validPairCount, 1);
      expect(rollups.single.averageConsumptionKmPerLiter, closeTo(10, 0.001));
      expect(rollups.single.averageCostPerKm, closeTo(0.56, 0.001));
    });

    test('resumo mensal por veículo inclui consumo quando há par válido', () {
      final list = FuelMetricsEngine.buildVehicleMonthlySummaries(
        records: records,
        now: DateTime(2026, 4, 25),
      );
      final v1 = list.firstWhere((s) => s.vehicleId == 'v1');
      expect(v1.averageConsumptionKmPerLiter, closeTo(10, 0.001));
      expect(v1.averageCostPerKm, closeTo(0.56, 0.001));
      final v2 = list.firstWhere((s) => s.vehicleId == 'v2');
      expect(v2.averageConsumptionKmPerLiter, isNull);
      expect(v2.averageCostPerKm, isNull);
    });
  });
}
