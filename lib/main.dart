import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DriveWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DriveWise'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Hola, Santiago',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona toda la información de tu vehículo desde un solo lugar.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
           Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.directions_car,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mi vehículo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Información principal del vehículo'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        const VehicleInfoRow(
          icon: Icons.directions_car_filled_outlined,
          label: 'Vehículo',
          value: 'Mazda 3 Touring',
        ),
        const SizedBox(height: 12),
        const VehicleInfoRow(
          icon: Icons.pin_outlined,
          label: 'Placa',
          value: 'ABC 123',
        ),
        const SizedBox(height: 12),
        const VehicleInfoRow(
          icon: Icons.speed_outlined,
          label: 'Kilometraje',
          value: '42.580 km',
        ),
        const SizedBox(height: 12),
        const VehicleInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Año',
          value: '2024',
        ),
      ],
    ),
  ),
),
            const SizedBox(height: 24),
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.build_outlined,
                    title: 'Mantenimiento',
                    value: '2 pendientes',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.notifications_outlined,
                    title: 'Recordatorios',
                    value: '3 activos',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
class VehicleInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VehicleInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}