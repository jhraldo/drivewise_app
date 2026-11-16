import '../../domain/models/modelo_vehiculo.dart';
import '../services/nhtsa_service.dart';
import 'datos_exception.dart';

// Convierte la respuesta del catálogo vPIC en una lista de modelos.
class CatalogoRepository {
  final NhtsaService _service;

  CatalogoRepository(this._service);

  Future<List<ModeloVehiculo>> buscarModelos({
    required String marca,
    required int anio,
    required bool esMotocicleta,
  }) {
    return proteger(() async {
      final json = await _service.obtenerModelos(
        marca: marca,
        anio: anio,
        esMotocicleta: esMotocicleta,
      );

      final lista = json['Results'] as List<dynamic>;

      final modelos = lista
          .map((e) => ModeloVehiculo.fromJson(e as Map<String, dynamic>))
          .toList();

      return _sinRepetidos(modelos);
    });
  }

  // El catálogo puede repetir un modelo; se deja uno por nombre y en orden alfabético.
  List<ModeloVehiculo> _sinRepetidos(List<ModeloVehiculo> modelos) {
    final vistos = <String>{};
    final resultado = <ModeloVehiculo>[];

    for (final modelo in modelos) {
      if (vistos.add(modelo.nombre.toUpperCase())) {
        resultado.add(modelo);
      }
    }

    resultado.sort((a, b) => a.nombre.compareTo(b.nombre));
    return resultado;
  }
}
