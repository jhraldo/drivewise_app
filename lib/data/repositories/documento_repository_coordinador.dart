
import '../../domain/entities/documento.dart';
import '../../domain/repositories/documento_repository.dart';
import '../firestore/firestore_documento_repository.dart';
import '../sqlite/sqlite_documento_repository.dart';

class DocumentoRepositoryCoordinador implements DocumentoRepository {
  DocumentoRepositoryCoordinador({
    required this.firestore,
    required this.sqlite,
  });

  final FirestoreDocumentoRepository firestore;
  final SqliteDocumentoRepository sqlite;

  // Sincroniza documentos nuevos y modificados.
  Future<void> _sincronizarPendientes(String vehiculoId) async {
    final pendientes = await sqlite.obtenerPendientes(vehiculoId);

    for (final documento in pendientes) {
      await firestore.guardar(documento);

      await sqlite.marcarComoSincronizado(
        documento.id,
        documento.vehiculoId,
      );
    }
  }

  // Sincroniza las eliminaciones pendientes.
  Future<void> _sincronizarEliminaciones(String vehiculoId) async {
    final eliminaciones =
        await sqlite.obtenerEliminacionesPendientes(vehiculoId);

    for (final eliminacion in eliminaciones) {
      final documentoId = eliminacion['documento_id'] as String;
      final idVehiculo = eliminacion['vehiculo_id'] as String;

      await firestore.eliminar(documentoId, idVehiculo);

      await sqlite.marcarEliminacionComoSincronizada(
        documentoId,
        idVehiculo,
      );
    }
  }

  @override
  Future<List<Documento>> obtenerPorVehiculo(String vehiculoId) async {
    try {
      // Primero sincroniza las operaciones pendientes.
      await _sincronizarPendientes(vehiculoId);
      await _sincronizarEliminaciones(vehiculoId);

      // Después consulta Firestore.
      final documentosNube =
          await firestore.obtenerPorVehiculo(vehiculoId);

      // Actualiza SQLite sin sobrescribir cambios locales pendientes.
      for (final documento in documentosNube) {
        await sqlite.guardarDesdeFirestore(documento);
      }

      return await sqlite.obtenerPorVehiculo(vehiculoId);
    } catch (_) {
      // Si falla Firestore, utiliza los datos locales.
      return await sqlite.obtenerPorVehiculo(vehiculoId);
    }
  }

  @override
  Future<void> guardar(Documento documento) async {
    await sqlite.guardar(documento);

    try {
      await firestore.guardar(documento);

      await sqlite.marcarComoSincronizado(
        documento.id,
        documento.vehiculoId,
      );
    } catch (_) {
      // Permanece pendiente en SQLite.
    }
  }

  @override
  Future<void> actualizar(Documento documento) async {
    await sqlite.actualizar(documento);

    try {
      await firestore.guardar(documento);

      await sqlite.marcarComoSincronizado(
        documento.id,
        documento.vehiculoId,
      );
    } catch (_) {
      // Permanece pendiente en SQLite.
    }
  }

  @override
  Future<void> eliminar(String documentoId, String vehiculoId) async {
    // Primero registra la eliminación en SQLite.
    await sqlite.eliminar(documentoId, vehiculoId);

    try {
      // Intenta eliminarlo inmediatamente de Firestore.
      await firestore.eliminar(documentoId, vehiculoId);

      // Si funciona, retira el registro de eliminación pendiente.
      await sqlite.marcarEliminacionComoSincronizada(
        documentoId,
        vehiculoId,
      );
    } catch (_) {
      // Si falla, la eliminación queda pendiente en SQLite.
    }
  }
}
