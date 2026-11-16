import 'package:flutter/material.dart';

import '../view_models/llamados_view_model.dart';
import 'detalle_llamado_pantalla.dart';

// Lista de llamados a revisión del vehículo, consultados en NHTSA.
class LlamadosPantalla extends StatefulWidget {
  final LlamadosViewModel viewModel;

  const LlamadosPantalla({
    super.key,
    required this.viewModel,
  });

  @override
  State<LlamadosPantalla> createState() => _LlamadosPantallaState();
}

class _LlamadosPantallaState extends State<LlamadosPantalla> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.cargar();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Llamados a revisión'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          if (viewModel.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return _mensaje(
              icono: Icons.cloud_off,
              texto: viewModel.error!,
              conReintentar: true,
            );
          }

          if (viewModel.sinInformacion) {
            return _mensaje(
              icono: Icons.help_outline,
              texto: 'NHTSA no tiene información de ${viewModel.marca} '
                  '${viewModel.modelo} ${viewModel.anio}. '
                  'Solo incluye vehículos vendidos en Estados Unidos.',
              conReintentar: false,
            );
          }

          if (viewModel.llamados.isEmpty) {
            return _mensaje(
              icono: Icons.verified,
              texto: 'Tu ${viewModel.marca} ${viewModel.modelo} '
                  '${viewModel.anio} no tiene llamados a revisión registrados.',
              conReintentar: false,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${viewModel.llamados.length} '
                '${viewModel.llamados.length == 1 ? 'llamado encontrado' : 'llamados encontrados'} '
                'para ${viewModel.marca} ${viewModel.modelo} ${viewModel.anio}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...viewModel.llamados.map((llamado) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.warning_amber, color: colors.error),
                    title: Text(llamado.componente),
                    subtitle: Text(
                      'Campaña ${llamado.numeroCampania}'
                      '${llamado.fechaReporte.isEmpty ? '' : ' • ${llamado.fechaReporte}'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleLlamadoPantalla(llamado: llamado),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text(
                'Fuente: NHTSA (EE. UU.). La información está en inglés.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mensaje({
    required IconData icono,
    required String texto,
    required bool conReintentar,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56),
            const SizedBox(height: 16),
            Text(texto, textAlign: TextAlign.center),
            if (conReintentar) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.viewModel.cargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
