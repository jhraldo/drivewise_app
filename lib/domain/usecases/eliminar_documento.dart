import '../repositories/documento_repository.dart';

class EliminarDocumento {
  EliminarDocumento(this._repository);

  final DocumentoRepository _repository;

  Future<void> call(String documentoId, String vehiculoId) {
    return _repository.eliminar(documentoId, vehiculoId);
  }
}