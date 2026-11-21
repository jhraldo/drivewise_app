
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/documento.dart';

class DocumentoDto {
  const DocumentoDto({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.numero,
    required this.fechaExpedicion,
    this.fechaVencimiento,
    this.soporteUrl,
    this.soporteLocalPath,
    this.soporteBytes,
    this.soporteNombre,
    this.soporteMimeType,
    this.pendienteSincronizacion = false,
  });

  final String id;
  final String vehiculoId;
  final String tipo;
  final String numero;
  final DateTime fechaExpedicion;
  final DateTime? fechaVencimiento;

  final String? soporteUrl;
  final String? soporteLocalPath;

  // Información del archivo almacenado localmente.
  final Uint8List? soporteBytes;
  final String? soporteNombre;
  final String? soporteMimeType;

  final bool pendienteSincronizacion;

  // Convierte un documento de Firestore en DTO.
  factory DocumentoDto.desdeFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String vehiculoId,
  ) {
    final datos = doc.data();

    final fechaExpedicion = datos['fechaExpedicion'];

    if (fechaExpedicion is! Timestamp) {
      throw FormatException(
        'El documento ${doc.id} no tiene una fecha de expedición válida.',
      );
    }

    final fechaVencimiento = datos['fechaVencimiento'];

    return DocumentoDto(
      id: doc.id,
      vehiculoId: vehiculoId,
      tipo: datos['tipo'] as String? ?? '',
      numero: datos['numero'] as String? ?? '',
      fechaExpedicion: fechaExpedicion.toDate(),
      fechaVencimiento: fechaVencimiento == null
          ? null
          : (fechaVencimiento as Timestamp).toDate(),
      soporteUrl: datos['soporteUrl'] as String?,
      soporteLocalPath: null,
      soporteBytes: null,
      soporteNombre: null,
      soporteMimeType: null,
      pendienteSincronizacion: false,
    );
  }

  // Convierte una fila SQLite en DTO.
  factory DocumentoDto.desdeFila(Map<String, Object?> fila) {
    return DocumentoDto(
      id: fila['id'] as String,
      vehiculoId: fila['vehiculo_id'] as String,
      tipo: fila['tipo'] as String? ?? '',
      numero: fila['numero'] as String? ?? '',
      fechaExpedicion: DateTime.parse(
        fila['fecha_expedicion'] as String,
      ),
      fechaVencimiento: fila['fecha_vencimiento'] == null
          ? null
          : DateTime.parse(
              fila['fecha_vencimiento'] as String,
            ),
      soporteUrl: fila['soporte_url'] as String?,
      soporteLocalPath: fila['soporte_local_path'] as String?,
      soporteBytes: _convertirBytes(fila['soporte_bytes']),
      soporteNombre: fila['soporte_nombre'] as String?,
      soporteMimeType: fila['soporte_mime_type'] as String?,
      pendienteSincronizacion:
          fila['pendiente_sincronizacion'] == 1,
    );
  }

  // Convierte los bytes recuperados de SQLite en Uint8List.
  static Uint8List? _convertirBytes(Object? valor) {
    if (valor == null) {
      return null;
    }

    if (valor is Uint8List) {
      return valor;
    }

    if (valor is List<int>) {
      return Uint8List.fromList(valor);
    }

    throw FormatException(
      'El formato de los bytes del archivo almacenado no es válido.',
    );
  }

  // Convierte el DTO en la entidad del dominio.
  Documento aEntidad() {
    return Documento(
      id: id,
      vehiculoId: vehiculoId,
      tipo: tipo,
      numero: numero,
      fechaExpedicion: fechaExpedicion,
      fechaVencimiento: fechaVencimiento,
      soporteUrl: soporteUrl,
      soporteLocalPath: soporteLocalPath,
      soporteBytes: soporteBytes,
      soporteNombre: soporteNombre,
      soporteMimeType: soporteMimeType,
    );
  }
}
