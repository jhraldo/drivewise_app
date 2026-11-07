import 'package:flutter/material.dart';

class MantenimientoPage extends StatelessWidget {
  const MantenimientoPage({super.key});

  static const _services = [
    MaintenanceItem(
      'Cambio de aceite y filtro',
      'Cada 3.000 km',
      'Faltan 1.250 km',
      Icons.oil_barrel,
    ),
    MaintenanceItem(
      'Revisión de frenos',
      'Cada 5.000 km',
      'Faltan 2.000 km',
      Icons.disc_full,
    ),
    MaintenanceItem(
      'Cambio de llantas',
      'Cada 15.000 km',
      'Faltan 2.550 km',
      Icons.tire_repair,
    ),
    MaintenanceItem(
      'Revisión de batería',
      'Cada 10.000 km',
      'Faltan 4.500 km',
      Icons.battery_full,
    ),
    MaintenanceItem(
      'Cambio de filtros',
      'Cada 6.000 km',
      'Faltan 3.550 km',
      Icons.filter_alt,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mantenimiento'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Resumen'),
              Tab(text: 'Próximos'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colors.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(Icons.two_wheeler, size: 56, color: colors.primary),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yamaha FZ 2.0',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('ABC12D • 2022'),
                        SizedBox(height: 4),
                        Text('12.450 km'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SummaryTab(services: _services),
                  _ServicesList(services: _services),
                  const _HistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaintenanceItem {
  const MaintenanceItem(this.title, this.frequency, this.remaining, this.icon);
  final String title;
  final String frequency;
  final String remaining;
  final IconData icon;
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.services});
  final List<MaintenanceItem> services;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: colors.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.event_available,
                  size: 42,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximo mantenimiento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Cambio de aceite y filtro'),
                      SizedBox(height: 4),
                      Text('Faltan 1.250 km o 28 días'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Estado general', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _StateRow(
                icon: Icons.settings,
                label: 'Motor',
                status: 'Óptimo',
                color: colors.primary,
              ),
              const Divider(height: 1),
              _StateRow(
                icon: Icons.tire_repair,
                label: 'Llantas',
                status: 'Óptimo',
                color: colors.primary,
              ),
              const Divider(height: 1),
              _StateRow(
                icon: Icons.disc_full,
                label: 'Frenos',
                status: 'Revisar',
                color: colors.tertiary,
              ),
              const Divider(height: 1),
              _StateRow(
                icon: Icons.battery_full,
                label: 'Batería',
                status: 'Óptimo',
                color: colors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Próximos servicios',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 370,
          child: _ServicesList(services: services, shrinkWrap: true),
        ),
      ],
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.services, this.shrinkWrap = false});
  final List<MaintenanceItem> services;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(4),
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(service.icon, color: colors.onPrimaryContainer),
            ),
            title: Text(
              service.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(service.frequency),
            trailing: SizedBox(
              width: 88,
              child: Text(
                service.remaining,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();
  static const _history = [
    '20 dic 2024 · Cambio de aceite',
    '15 nov 2024 · Revisión de frenos',
    '10 sep 2024 · Revisión general',
    '05 jul 2024 · Cambio de filtros',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: Icon(Icons.check_circle, color: colors.primary),
          title: Text(_history[index]),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(label),
    trailing: Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    ),
  );
}
