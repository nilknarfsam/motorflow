class FuelSettings {
  const FuelSettings({
    required this.precoPadraoGasolina,
    required this.precoPadraoEtanol,
    required this.precoPadraoDiesel,
  });

  final double precoPadraoGasolina;
  final double precoPadraoEtanol;
  final double precoPadraoDiesel;

  FuelSettings copyWith({
    double? precoPadraoGasolina,
    double? precoPadraoEtanol,
    double? precoPadraoDiesel,
  }) {
    return FuelSettings(
      precoPadraoGasolina: precoPadraoGasolina ?? this.precoPadraoGasolina,
      precoPadraoEtanol: precoPadraoEtanol ?? this.precoPadraoEtanol,
      precoPadraoDiesel: precoPadraoDiesel ?? this.precoPadraoDiesel,
    );
  }
}
