import 'package:flutter/material.dart';

import '../../../data/repositories/imagenes_repository.dart';
import '../../../data/services/wikipedia_service.dart';
import '../view_models/imagen_vehiculo_view_model.dart';

// Muestra la foto del modelo tomada de Wikipedia.
// Mientras carga, o si no hay foto, muestra el ícono de carro o moto.
//
// Al usarla se le da una key con el id del vehículo, para que la imagen
// se vuelva a buscar cuando el usuario cambia de vehículo.
class ImagenVehiculoTarjeta extends StatefulWidget {
  final String marca;
  final String modelo;
  final bool esMotocicleta;

  const ImagenVehiculoTarjeta({
    super.key,
    required this.marca,
    required this.modelo,
    required this.esMotocicleta,
  });

  @override
  State<ImagenVehiculoTarjeta> createState() => _ImagenVehiculoTarjetaState();
}

class _ImagenVehiculoTarjetaState extends State<ImagenVehiculoTarjeta> {
  late final ImagenVehiculoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ImagenVehiculoViewModel(
      ImagenesRepository(WikipediaService()),
      marca: widget.marca,
      modelo: widget.modelo,
    );
    _viewModel.cargar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final icono = Icon(
      widget.esMotocicleta ? Icons.two_wheeler : Icons.directions_car,
      size: 100,
      color: colors.primary,
    );

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.cargando) {
          return SizedBox(
            height: 180,
            child: Center(child: icono),
          );
        }

        final imagen = _viewModel.imagen;

        if (imagen == null) {
          return Column(
            children: [
              icono,
              // Solo hay botón si falló la red; si Wikipedia no tiene foto, no.
              if (_viewModel.fallo)
                TextButton.icon(
                  onPressed: _viewModel.cargar,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar imagen'),
                ),
            ],
          );
        }

        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagen.urlImagen,
                headers: WikipediaService.encabezados,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                // Si la foto no se puede descargar, se vuelve al ícono.
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  height: 180,
                  child: Center(child: icono),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              imagen.descripcion.isEmpty
                  ? 'Imagen: Wikipedia'
                  : '${imagen.descripcion} • Imagen: Wikipedia',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}
