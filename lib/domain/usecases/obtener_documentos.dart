import '../entities/documento.dart';
import '../repositories/documento_repository.dart';

class ObtenerDocumentos {
  ObtenerDocumentos(this._repository);

  final DocumentoRepository _repository;

  Future<List<Documento>> call(String vehiculoId) {
    return _repository.obtenerPorVehiculo(vehiculoId);
  }
}