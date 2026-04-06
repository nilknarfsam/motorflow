import 'package:flutter_test/flutter_test.dart';
import 'package:motorflow/data/repositories/in_memory_motorflow_repository.dart';
import 'package:motorflow/presentation/app.dart';

void main() {
  testWidgets('renderiza abas principais', (WidgetTester tester) async {
    await tester.pumpWidget(
      MotorflowApp(repository: InMemoryMotorflowRepository()),
    );

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Veiculos'), findsWidgets);
    expect(find.text('Manutencoes'), findsWidgets);
    expect(find.text('Abastecimentos'), findsWidgets);
  });
}
