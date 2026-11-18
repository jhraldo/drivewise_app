import '../entities/documento.dart';
import '../repositories/documento_repository.dart';

class ActualizarDocumento {
  ActualizarDocumento(this._repository);

  final DocumentoRepository _repository;

  Future<void> call(Documento documento) {
    return _repository.actualizar(documento);
  }
}