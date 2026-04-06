class Vehicle {
  const Vehicle({
    required this.id,
    required this.nome,
    required this.modelo,
    required this.ano,
    required this.kmAtual,
  });

  final String id;
  final String nome;
  final String modelo;
  final int ano;
  final int kmAtual;
}
