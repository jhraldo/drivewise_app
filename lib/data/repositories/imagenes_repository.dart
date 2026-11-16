import '../../domain/models/imagen_vehiculo.dart';
import '../services/wikipedia_service.dart';
import 'datos_exception.dart';

// Busca la imagen de un modelo en Wikipedia.
// Devuelve null si el artículo existe pero no tiene una foto útil.
class ImagenesRepository {
  final WikipediaService _service;

  ImagenesRepository(this._service);

  Future<ImagenVehiculo?> buscarImagen({
    required String marca,
    required String modelo,
  }) {
    return proteger(() async {
      // Los artículos se llaman "Marca Modelo", por ejemplo "Honda Pilot".
      final json = await _service.obtenerResumen('$marca $modelo');

      return ImagenVehiculo.desdeJson(json);
    });
  }
}
