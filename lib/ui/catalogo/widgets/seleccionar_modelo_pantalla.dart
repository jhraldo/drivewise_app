import 'package:flutter/material.dart';

import '../view_models/catalogo_view_model.dart';

// Muestra los modelos del catálogo de NHTSA y devuelve el nombre elegido
// con Navigator.pop(context, nombre).
class SeleccionarModeloPantalla extends StatefulWidget {
  final CatalogoViewModel viewModel;

  const SeleccionarModeloPantalla({
    super.key,
    required this.viewModel,
  });

  @override
  State<SeleccionarModeloPantalla> createState() =>
      _SeleccionarModeloPantallaState();
}

class _SeleccionarModeloPantallaState
    extends State<SeleccionarModeloPantalla> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Modelos ${viewModel.marca} ${viewModel.anio}'),
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

          if (viewModel.modelos.isEmpty) {
            return _mensaje(
              icono: Icons.search_off,
              texto: 'No encontramos modelos de ${viewModel.marca} '
                  'para el año ${viewModel.anio}. '
                  'Puedes escribir el modelo a mano en el formulario.',
              conReintentar: false,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: viewModel.modelos.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final modelo = viewModel.modelos[index];

                    return ListTile(
                      leading: Icon(
                        viewModel.esMotocicleta
                            ? Icons.two_wheeler
                            : Icons.directions_car,
                      ),
                      title: Text(modelo.nombre),
                      subtitle: Text(modelo.marca),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, modelo.nombre),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Fuente: catálogo vPIC de NHTSA (EE. UU.)',
                  style: TextStyle(fontSize: 12),
                ),
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
