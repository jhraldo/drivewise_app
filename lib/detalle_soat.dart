import 'package:flutter/material.dart';

class DetalleSoatPage extends StatelessWidget {
  const DetalleSoatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle SOAT'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 70,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'SOAT',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Vigente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const InfoSoatRow(
            icon: Icons.calendar_today_outlined,
            titulo: 'Fecha de expedición',
            valor: '15/01/2026',
          ),

          const Divider(),

          const InfoSoatRow(
            icon: Icons.event_outlined,
            titulo: 'Fecha de vencimiento',
            valor: '15/01/2027',
          ),

          const Divider(),

          const InfoSoatRow(
            icon: Icons.business_outlined,
            titulo: 'Compañía aseguradora',
            valor: 'SURA',
          ),

          const Divider(),

          const InfoSoatRow(
            icon: Icons.confirmation_number_outlined,
            titulo: 'Número de póliza',
            valor: 'SOAT-2026-45821',
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active_outlined,
              ),

              title: const Text(
                'Recordatorio de vencimiento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'Te avisaremos antes del vencimiento del SOAT.',
              ),

              trailing: Switch(
                value: true,
                onChanged: (valor) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoSoatRow extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const InfoSoatRow({
    super.key,
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}