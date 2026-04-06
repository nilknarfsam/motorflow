class Maintenance {
  const Maintenance({
    required this.id,
    required this.vehicleId,
    required this.tipo,
    required this.descricao,
    required this.kmTroca,
    required this.dataTroca,
    required this.kmProximaTroca,
    required this.dataProximaTroca,
    required this.custo,
  });

  final String id;
  final String vehicleId;
  final String tipo;
  final String descricao;
  final int kmTroca;
  final DateTime dataTroca;
  final int kmProximaTroca;
  final DateTime dataProximaTroca;
  final double custo;
}
