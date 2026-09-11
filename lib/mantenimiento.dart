import 'package:flutter/material.dart';

class MantenimientoPage extends StatelessWidget {
  const MantenimientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mantenimientos = [
      {
        'titulo': 'Cambio de aceite y filtro',
        'descripcion': 'Cada 3.000 km',
        'kilometros': 'Faltan 1.250 km',
        'icono': Icons.build,
      },
      {
        'titulo': 'Revisión general',
        'descripcion': 'Cada 6.000 km',
        'kilometros': 'Faltan 3.550 km',
        'icono': Icons.handyman,
      },
      {
        'titulo': 'Revisión de frenos',
        'descripcion': 'Cada 5.000 km',
        'kilometros': 'Faltan 2.000 km',
        'icono': Icons.disc_full,
      },
      {
        'titulo': 'Revisión de batería',
        'descripcion': 'Cada 10.000 km',
        'kilometros': 'Faltan 4.500 km',
        'icono': Icons.battery_full,
      },
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mantenimiento'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Información del vehículo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.two_wheeler,
                    size: 70,
                  ),
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
                        SizedBox(height: 6),
                        Text(
                          'ABC12D • 2022',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '12.450 km',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cambiar vehículo'),
                  ),
                ],
              ),
            ),

            const TabBar(
              tabs: [
                Tab(text: 'Resumen'),
                Tab(text: 'Próximos servicios'),
                Tab(text: 'Historial'),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _ResumenMantenimiento(
                    mantenimientos: mantenimientos,
                  ),
                  _ProximosServicios(
                    mantenimientos: mantenimientos,
                  ),
                  const _HistorialMantenimiento(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenMantenimiento extends StatelessWidget {
  final List<Map<String, dynamic>> mantenimientos;

  const _ResumenMantenimiento({
    required this.mantenimientos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Próximo servicio
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available,
                  color: Colors.green,
                  size: 45,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximo servicio recomendado',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '15 de marzo de 2025',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Faltan 1.250 km o 28 días'),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Ver detalles'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Estadísticas
       Row(
  children: [
    Expanded(
      child: _StatisticCard(
        title: 'Kilometraje actual',
        value: '12.450 km',
        icon: Icons.speed,
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: _StatisticCard(
        title: 'Último servicio',
        value: '20 dic 2024',
        icon: Icons.calendar_month,
      ),
    ),
  ],
),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _StatisticCard(
                title: 'Servicios realizados',
                value: '5',
                icon: Icons.build,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatisticCard(
                title: 'Gasto total',
                value: '\$850.000',
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Estado general
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado general',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu moto se encuentra en buen estado.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const Divider(),

                _EstadoRow(
                  icon: Icons.settings,
                  titulo: 'Motor',
                  estado: 'Óptimo',
                  color: Colors.green,
                ),
                _EstadoRow(
                  icon: Icons.tire_repair,
                  titulo: 'Llantas',
                  estado: 'Óptimo',
                  color: Colors.green,
                ),
                _EstadoRow(
                  icon: Icons.disc_full,
                  titulo: 'Frenos',
                  estado: 'Regular',
                  color: Colors.orange,
                ),
                _EstadoRow(
                  icon: Icons.battery_full,
                  titulo: 'Batería',
                  estado: 'Óptimo',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Próximos servicios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // LISTVIEW.BUILDER
        SizedBox(
          height: 350,
          child: ListView.builder(
            itemCount: mantenimientos.length,
            itemBuilder: (context, index) {
              final mantenimiento = mantenimientos[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: Icon(
                      mantenimiento['icono'] as IconData,
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    mantenimiento['titulo'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    mantenimiento['descripcion'] as String,
                  ),
                  trailing: Text(
                    mantenimiento['kilometros'] as String,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProximosServicios extends StatelessWidget {
  final List<Map<String, dynamic>> mantenimientos;

  const _ProximosServicios({
    required this.mantenimientos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mantenimientos.length,
      itemBuilder: (context, index) {
        final item = mantenimientos[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(
                item['icono'] as IconData,
                color: Colors.green,
              ),
            ),
            title: Text(
              item['titulo'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              item['descripcion'] as String,
            ),
            trailing: Text(
              item['kilometros'] as String,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistorialMantenimiento extends StatelessWidget {
  const _HistorialMantenimiento();

  @override
  Widget build(BuildContext context) {
    final historial = [
      '20 dic 2024 - Cambio de aceite',
      '15 nov 2024 - Revisión de frenos',
      '10 sep 2024 - Revisión general',
      '05 jul 2024 - Cambio de filtro',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historial.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: Text(historial[index]),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoRow extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String estado;
  final Color color;

  const _EstadoRow({
    required this.icon,
    required this.titulo,
    required this.estado,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(titulo),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            estado,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}