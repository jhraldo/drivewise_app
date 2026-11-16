import '../../domain/models/llamado_revision.dart';
import '../services/nhtsa_service.dart';
import 'datos_exception.dart';

// Convierte la respuesta de la API de llamados a revisión en una lista de modelos.
class LlamadosRepository {
  final NhtsaService _service;

  LlamadosRepository(this._service);

  Future<List<LlamadoRevision>> buscarLlamados({
    required String marca,
    required String modelo,
    required int anio,
  }) {
    return proteger(() async {
      final json = await _service.obtenerLlamados(
        marca: marca,
        modelo: modelo,
        anio: anio,
      );

      // Esta API usa "results" en minúscula, a diferencia de vPIC.
      final lista = (json['results'] ?? json['Results']) as List<dynamic>;

      return lista
          .map((e) => LlamadoRevision.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
