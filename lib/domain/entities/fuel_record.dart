class FuelRecord {
  const FuelRecord({
    required this.id,
    required this.vehicleId,
    required this.data,
    required this.kmAtual,
    required this.precoLitro,
    required this.valorTotal,
    required this.litros,
    required this.nomePosto,
    required this.tipoCombustivel,
    required this.observacoes,
  });

  final String id;
  final String vehicleId;
  final DateTime data;
  final int kmAtual;
  final double precoLitro;
  final double valorTotal;
  final double litros;
  final String nomePosto;
  final String tipoCombustivel;
  final String observacoes;
}
