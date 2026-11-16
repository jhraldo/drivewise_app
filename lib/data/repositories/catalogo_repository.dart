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
      // Modelos de moto de la marca en ese año.
      final motos = _convertir(
        await _service.obtenerModelos(
          marca: marca,
          anio: anio,
          esMotocicleta: true,
        ),
      );

      if (esMotocicleta) {
        return _sinRepetidos(motos);
      }

      // Para un automóvil se piden todos los modelos y se quitan las motos.
      // No se filtra por el tipo "car" porque las camionetas (CX-5, Pilot)
      // están clasificadas como otro tipo y se perderían.
      final todos = _convertir(
        await _service.obtenerModelos(
          marca: marca,
          anio: anio,
          esMotocicleta: false,
        ),
      );

      final nombresMotos = motos.map((m) => m.nombre.toUpperCase()).toSet();

      final automoviles = todos
          .where((m) => !nombresMotos.contains(m.nombre.toUpperCase()))
          .toList();

      return _sinRepetidos(automoviles);
    });
  }

  List<ModeloVehiculo> _convertir(Map<String, dynamic> json) {
    final lista = json['Results'] as List<dynamic>;

    return lista
        .map((e) => ModeloVehiculo.fromJson(e as Map<String, dynamic>))
        .toList();
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
