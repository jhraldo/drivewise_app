
import '../entities/documento.dart';

abstract interface class DocumentoRepository {
  Future<List<Documento>> obtenerPorVehiculo(String vehiculoId);

  Future<void> guardar(Documento documento);

  Future<void> actualizar(Documento documento);

  Future<void> eliminar(String documentoId, String vehiculoId);
}
