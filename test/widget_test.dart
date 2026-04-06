import 'package:motorflow/data/local/memory_motorflow_local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorflow/data/repositories/in_memory_motorflow_repository.dart';
import 'package:motorflow/presentation/app.dart';

void main() {
  testWidgets('renderiza abas principais', (WidgetTester tester) async {
    final repository = await InMemoryMotorflowRepository.create(
      localStore: MemoryMotorflowLocalStore(),
    );
    await tester.pumpWidget(MotorflowApp(repository: repository));

    expect(find.text('Início'), findsWidgets);
    expect(find.text('Carros'), findsWidgets);
    expect(find.text('Serviços'), findsWidgets);
    expect(find.text('Combustível'), findsWidgets);
    expect(find.text('Ajustes'), findsWidgets);
  });
}
