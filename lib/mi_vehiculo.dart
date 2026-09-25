import 'package:flutter/material.dart';

import 'mantenimiento.dart';

class MiVehiculoPage extends StatelessWidget {
  const MiVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi vehículo'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.two_wheeler, size: 120, color: colors.primary),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yamaha FZ 2.0',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '2022 • Negro Mate',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(
                        label: 'Todo en orden',
                        color: colors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.badge, size: 32, color: colors.primary),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ABC12D',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Bogotá D.C.'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.speed,
                          title: '12.450 km',
                          subtitle: 'Kilometraje',
                        ),
                      ),
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.calendar_month,
                          title: '15 mar 2025',
                          subtitle: 'Próximo servicio',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Row(
                children: [
                  _QuickAction(
                    icon: Icons.build,
                    label: 'Mantenimiento',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MantenimientoPage(),
                      ),
                    ),
                  ),
                  const _QuickAction(
                    icon: Icons.local_gas_station,
                    label: 'Consumo',
                  ),
                  const _QuickAction(icon: Icons.shield, label: 'Seguro'),
                  const _QuickAction(
                    icon: Icons.description,
                    label: 'Documentos',
                  ),
                  const _QuickAction(
                    icon: Icons.warning_amber,
                    label: 'Alertas',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InformationCard(colors: colors),
          const SizedBox(height: 16),
          _VehicleStatusCard(colors: colors),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.route, color: colors.primary),
              title: const Text('Último viaje'),
              subtitle: const Text('Centro → Chapinero · 8,4 km'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.colors});
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                'Información general',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _GeneralInfo(title: 'Tipo', value: 'Motocicleta'),
              ),
              Expanded(
                child: _GeneralInfo(title: 'Cilindraje', value: '149 cc'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _GeneralInfo(
                  title: 'Transmisión',
                  value: '5 velocidades',
                ),
              ),
              Expanded(
                child: _GeneralInfo(title: 'Combustible', value: 'Gasolina'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _VehicleStatusCard extends StatelessWidget {
  const _VehicleStatusCard({required this.colors});
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado del vehículo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatusItem(
                  icon: Icons.settings,
                  title: 'Motor',
                  status: 'Óptimo',
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusItem(
                  icon: Icons.tire_repair,
                  title: 'Llantas',
                  status: 'Óptimo',
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatusItem(
                  icon: Icons.disc_full,
                  title: 'Frenos',
                  status: 'Regular',
                  color: colors.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusItem(
                  icon: Icons.battery_full,
                  title: 'Batería',
                  status: 'Óptimo',
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '✓ $label',
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    ),
  );
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(icon, color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneralInfo extends StatelessWidget {
  const _GeneralInfo({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ],
  );
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.title,
    required this.status,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String status;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 6),
        Text(title),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
