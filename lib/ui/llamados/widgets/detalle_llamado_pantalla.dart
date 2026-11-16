import 'package:flutter/material.dart';

import '../../../domain/models/llamado_revision.dart';

// Detalle de un llamado a revisión. Recibe el llamado por el constructor.
class DetalleLlamadoPantalla extends StatelessWidget {
  final LlamadoRevision llamado;

  const DetalleLlamadoPantalla({
    super.key,
    required this.llamado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaña ${llamado.numeroCampania}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            llamado.componente,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (llamado.fabricante.isNotEmpty) llamado.fabricante,
              if (llamado.fechaReporte.isNotEmpty)
                'Reportado: ${llamado.fechaReporte}',
            ].join(' • '),
          ),
          const SizedBox(height: 16),
          SeccionLlamado(titulo: 'Resumen', texto: llamado.resumen),
          SeccionLlamado(titulo: 'Consecuencia', texto: llamado.consecuencia),
          SeccionLlamado(titulo: 'Solución', texto: llamado.solucion),
          const SizedBox(height: 8),
          const Text(
            'Fuente: NHTSA (EE. UU.). Consulta con el concesionario si el '
            'llamado aplica a tu vehículo en Colombia.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Componente reutilizable: una tarjeta con título y texto.
class SeccionLlamado extends StatelessWidget {
  final String titulo;
  final String texto;

  const SeccionLlamado({
    super.key,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(texto),
          ],
        ),
      ),
    );
  }
}
