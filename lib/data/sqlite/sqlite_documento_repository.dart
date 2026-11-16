
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../domain/entities/documento.dart';
import '../../domain/repositories/documento_repository.dart';
import '../datos/documento_dto.dart';

class SqliteDocumentoRepository implements DocumentoRepository {
  SqliteDocumentoRepository(this._db);

  final Database _db;

  static Future<SqliteDocumentoRepository> abrir() async {
    // Configurar SQLite para Flutter Web.
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final ruta = join(
      await getDatabasesPath(),
      'drivewise_documentos.db',
    );

    final db = await openDatabase(
      ruta,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documentos (
            id TEXT PRIMARY KEY,
            vehiculo_id TEXT NOT NULL,
            tipo TEXT NOT NULL,
            numero TEXT NOT NULL,
            fecha_expedicion TEXT NOT NULL,
            fecha_vencimiento TEXT,
            soporte_url TEXT,
            soporte_local_path TEXT,
            soporte_bytes BLOB,
            soporte_nombre TEXT,
            soporte_mime_type TEXT,
            pendiente_sincronizacion INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE eliminaciones_pendientes (
            documento_id TEXT NOT NULL,
            vehiculo_id TEXT NOT NULL,
            PRIMARY KEY (documento_id, vehiculo_id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE documentos
            ADD COLUMN pendiente_sincronizacion INTEGER NOT NULL DEFAULT 0
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE eliminaciones_pendientes (
              documento_id TEXT NOT NULL,
              vehiculo_id TEXT NOT NULL,
              PRIMARY KEY (documento_id, vehiculo_id)
            )
          ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
            ALTER TABLE documentos
            ADD COLUMN soporte_local_path TEXT
          ''');
        }

        if (oldVersion < 5) {
          await db.execute('''
            ALTER TABLE documentos
            ADD COLUMN soporte_bytes BLOB
          ''');

          await db.execute('''
            ALTER TABLE documentos
            ADD COLUMN soporte_nombre TEXT
          ''');

          await db.execute('''
            ALTER TABLE documentos
            ADD COLUMN soporte_mime_type TEXT
          ''');
        }
      },
    );

    return SqliteDocumentoRepository(db);
  }

  // Consulta todos los documentos de un vehículo.
  @override
  Future<List<Documento>> obtenerPorVehiculo(String vehiculoId) async {
    final filas = await _db.query(
      'documentos',
      where: 'vehiculo_id = ?',
      whereArgs: [vehiculoId],
      orderBy: 'fecha_vencimiento ASC',
    );

    return filas
        .map((fila) => DocumentoDto.desdeFila(fila).aEntidad())
        .toList();
  }

  // Guarda un documento nuevo como pendiente de sincronización.
  @override
  Future<void> guardar(Documento documento) async {
    await _db.insert(
      'documentos',
      _aFila(documento, pendiente: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Guarda una copia de Firestore sin sobrescribir cambios locales
  // pendientes ni los archivos almacenados en el dispositivo.
  Future<void> guardarDesdeFirestore(Documento documento) async {
    await _db.transaction((txn) async {
      // No recuperar documentos que tienen una eliminación pendiente.
      final eliminacionPendiente = await txn.query(
        'eliminaciones_pendientes',
        columns: ['documento_id'],
        where: 'documento_id = ? AND vehiculo_id = ?',
        whereArgs: [documento.id, documento.vehiculoId],
        limit: 1,
      );

      if (eliminacionPendiente.isNotEmpty) {
        return;
      }

      // Consultar el registro local completo.
      final existentes = await txn.query(
        'documentos',
        where: 'id = ? AND vehiculo_id = ?',
        whereArgs: [documento.id, documento.vehiculoId],
        limit: 1,
      );

      // No sobrescribir cambios locales pendientes de sincronización.
      if (existentes.isNotEmpty &&
          existentes.first['pendiente_sincronizacion'] == 1) {
        return;
      }

      final fila = _aFila(documento, pendiente: false);

      // Firestore no contiene los bytes de los archivos.
      // Conservar los soportes que ya existen en SQLite.
      if (existentes.isNotEmpty) {
        final datosLocales = existentes.first;

        fila['soporte_bytes'] ??= datosLocales['soporte_bytes'];
        fila['soporte_nombre'] ??= datosLocales['soporte_nombre'];
        fila['soporte_mime_type'] ??= datosLocales['soporte_mime_type'];
        fila['soporte_local_path'] ??= datosLocales['soporte_local_path'];
      }

      await txn.insert(
        'documentos',
        fila,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // Actualiza un documento local y lo marca como pendiente.
  @override
  Future<void> actualizar(Documento documento) async {
    await _db.transaction((txn) async {
      final existentes = await txn.query(
        'documentos',
        where: 'id = ? AND vehiculo_id = ?',
        whereArgs: [documento.id, documento.vehiculoId],
        limit: 1,
      );

      if (existentes.isEmpty) {
        return;
      }

      final fila = _aFila(documento, pendiente: true);
      final datosLocales = existentes.first;

      // Si la actualización no trae un archivo nuevo, conservar
      // el soporte que ya estaba almacenado localmente.
      fila['soporte_bytes'] ??= datosLocales['soporte_bytes'];
      fila['soporte_nombre'] ??= datosLocales['soporte_nombre'];
      fila['soporte_mime_type'] ??= datosLocales['soporte_mime_type'];
      fila['soporte_local_path'] ??= datosLocales['soporte_local_path'];

      await txn.update(
        'documentos',
        fila,
        where: 'id = ? AND vehiculo_id = ?',
        whereArgs: [documento.id, documento.vehiculoId],
      );
    });
  }

  // Obtiene los documentos que todavía deben enviarse a Firestore.
  Future<List<Documento>> obtenerPendientes(String vehiculoId) async {
    final filas = await _db.query(
      'documentos',
      where: 'vehiculo_id = ? AND pendiente_sincronizacion = ?',
      whereArgs: [vehiculoId, 1],
    );

    return filas
        .map((fila) => DocumentoDto.desdeFila(fila).aEntidad())
        .toList();
  }

  // Marca un documento como sincronizado después de enviarlo a Firestore.
  Future<void> marcarComoSincronizado(
    String documentoId,
    String vehiculoId,
  ) async {
    await _db.update(
      'documentos',
      {'pendiente_sincronizacion': 0},
      where: 'id = ? AND vehiculo_id = ?',
      whereArgs: [documentoId, vehiculoId],
    );
  }

  // Obtiene las eliminaciones que todavía deben enviarse a Firestore.
  Future<List<Map<String, Object?>>> obtenerEliminacionesPendientes(
    String vehiculoId,
  ) async {
    return _db.query(
      'eliminaciones_pendientes',
      where: 'vehiculo_id = ?',
      whereArgs: [vehiculoId],
    );
  }

  // Confirma que una eliminación ya fue procesada en Firestore.
  Future<void> marcarEliminacionComoSincronizada(
    String documentoId,
    String vehiculoId,
  ) async {
    await _db.delete(
      'eliminaciones_pendientes',
      where: 'documento_id = ? AND vehiculo_id = ?',
      whereArgs: [documentoId, vehiculoId],
    );
  }

  // Registra la eliminación pendiente y borra el documento local.
  @override
  Future<void> eliminar(String documentoId, String vehiculoId) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'eliminaciones_pendientes',
        {
          'documento_id': documentoId,
          'vehiculo_id': vehiculoId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'documentos',
        where: 'id = ? AND vehiculo_id = ?',
        whereArgs: [documentoId, vehiculoId],
      );
    });
  }

  // Convierte la entidad Documento en una fila SQLite.
  Map<String, Object?> _aFila(
    Documento documento, {
    required bool pendiente,
  }) {
    return {
      'id': documento.id,
      'vehiculo_id': documento.vehiculoId,
      'tipo': documento.tipo,
      'numero': documento.numero,
      'fecha_expedicion': documento.fechaExpedicion.toIso8601String(),
      'fecha_vencimiento':
          documento.fechaVencimiento?.toIso8601String(),
      'soporte_url': documento.soporteUrl,
      'soporte_local_path': documento.soporteLocalPath,
      'soporte_bytes': documento.soporteBytes,
      'soporte_nombre': documento.soporteNombre,
      'soporte_mime_type': documento.soporteMimeType,
      'pendiente_sincronizacion': pendiente ? 1 : 0,
    };
  }
}
