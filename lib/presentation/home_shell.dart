import 'package:flutter/material.dart';
import 'package:motorflow/domain/repositories/motorflow_repository.dart';
import 'package:motorflow/features/dashboard/presentation/dashboard_page.dart';
import 'package:motorflow/features/fuel/presentation/fuel_page.dart';
import 'package:motorflow/features/maintenance/presentation/maintenance_page.dart';
import 'package:motorflow/features/settings/presentation/settings_page.dart';
import 'package:motorflow/features/vehicle/presentation/vehicle_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});

  final MotorflowRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(repository: widget.repository),
      VehiclePage(repository: widget.repository),
      MaintenancePage(repository: widget.repository),
      FuelPage(repository: widget.repository),
      SettingsPage(repository: widget.repository),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Veiculos',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Manutencoes',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station),
            label: 'Abastecimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configuracoes',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
