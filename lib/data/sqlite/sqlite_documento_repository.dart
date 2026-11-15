
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/documento.dart';
import '../../domain/repositories/documento_repository.dart';

class SqliteDocumentoRepository implements DocumentoRepository {
  SqliteDocumentoRepository(this._db);

  final Database _db;

  static Future<SqliteDocumentoRepository> abrir() async {
    final ruta = join(
      await getDatabasesPath(),
      'drivewise_documentos.db',
    );

    final db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documentos (
            id TEXT PRIMARY KEY,
            vehiculo_id TEXT NOT NULL,
            tipo TEXT NOT NULL,
            numero TEXT NOT NULL,
            fecha_expedicion TEXT NOT NULL,
            fecha_vencimiento TEXT,
            soporte_url TEXT
          )
        ''');
      },
    );

    return SqliteDocumentoRepository(db);
  }

  @override
  Future<List<Documento>> obtenerPorVehiculo(String vehiculoId) async {
    final filas = await _db.query(
      'documentos',
      where: 'vehiculo_id = ?',
      whereArgs: [vehiculoId],
      orderBy: 'fecha_vencimiento ASC',
    );

    return filas.map((fila) {
      return Documento(
        id: fila['id'] as String,
        vehiculoId: fila['vehiculo_id'] as String,
        tipo: fila['tipo'] as String,
        numero: fila['numero'] as String,
        fechaExpedicion:
            DateTime.parse(fila['fecha_expedicion'] as String),
        fechaVencimiento: fila['fecha_vencimiento'] == null
            ? null
            : DateTime.parse(fila['fecha_vencimiento'] as String),
        soporteUrl: fila['soporte_url'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> guardar(Documento documento) async {
    await _db.insert(
      'documentos',
      _aFila(documento),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> actualizar(Documento documento) async {
    await _db.update(
      'documentos',
      _aFila(documento),
      where: 'id = ? AND vehiculo_id = ?',
      whereArgs: [documento.id, documento.vehiculoId],
    );
  }

  @override
  Future<void> eliminar(String documentoId, String vehiculoId) async {
    await _db.delete(
      'documentos',
      where: 'id = ? AND vehiculo_id = ?',
      whereArgs: [documentoId, vehiculoId],
    );
  }

  Map<String, Object?> _aFila(Documento documento) {
    return {
      'id': documento.id,
      'vehiculo_id': documento.vehiculoId,
      'tipo': documento.tipo,
      'numero': documento.numero,
      'fecha_expedicion': documento.fechaExpedicion.toIso8601String(),
      'fecha_vencimiento':
          documento.fechaVencimiento?.toIso8601String(),
      'soporte_url': documento.soporteUrl,
    };
  }
}
