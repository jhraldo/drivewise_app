import 'package:flutter/material.dart';
import 'detalle_soat.dart';

class RecordatoriosPage extends StatelessWidget {
  const RecordatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Próximos vencimientos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          const Text(
            'Mantente al día con los documentos y mantenimientos de tu vehículo.',
          ),

          const SizedBox(height: 24),

          RecordatorioCard(
            icon: Icons.description_outlined,
            titulo: 'SOAT',
            descripcion: 'Vence en 28 días',
            colorIcono: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetalleSoatPage(),
                ),
              );
            },
          ),

          RecordatorioCard(
            icon: Icons.fact_check_outlined,
            titulo: 'Tecnomecánica',
            descripcion: 'Vence en 45 días',
            colorIcono: Colors.orange,
          ),

          RecordatorioCard(
            icon: Icons.shield_outlined,
            titulo: 'Seguro',
            descripcion: 'Vence en 60 días',
            colorIcono: Colors.blue,
          ),

          RecordatorioCard(
            icon: Icons.oil_barrel_outlined,
            titulo: 'Cambio de aceite',
            descripcion: 'Programado en 1.250 km',
            colorIcono: Colors.amber,
          ),

          RecordatorioCard(
            icon: Icons.tire_repair,
            titulo: 'Revisión de llantas',
            descripcion: 'Programada en 2.000 km',
            colorIcono: Colors.green,
          ),
        ],
      ),
    );
  }
}

class RecordatorioCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color colorIcono;
  final VoidCallback? onTap;

  const RecordatorioCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.colorIcono,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(child: Icon(icon)),

        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(descripcion),

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
