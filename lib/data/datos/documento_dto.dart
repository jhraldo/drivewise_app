
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
  });

  final String id;
  final String vehiculoId;
  final String tipo;
  final String numero;
  final DateTime fechaExpedicion;
  final DateTime? fechaVencimiento;
  final String? soporteUrl;

  factory DocumentoDto.desdeFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String vehiculoId,
  ) {
    final datos = doc.data();

    return DocumentoDto(
      id: doc.id,
      vehiculoId: vehiculoId,
      tipo: datos['tipo'] as String,
      numero: datos['numero'] as String,
      fechaExpedicion:
          (datos['fechaExpedicion'] as Timestamp).toDate(),
      fechaVencimiento: datos['fechaVencimiento'] == null
          ? null
          : (datos['fechaVencimiento'] as Timestamp).toDate(),
      soporteUrl: datos['soporteUrl'] as String?,
    );
  }

  factory DocumentoDto.desdeFila(Map<String, Object?> fila) {
    return DocumentoDto(
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
  }

  Documento aEntidad() {
    return Documento(
      id: id,
      vehiculoId: vehiculoId,
      tipo: tipo,
      numero: numero,
      fechaExpedicion: fechaExpedicion,
      fechaVencimiento: fechaVencimiento,
      soporteUrl: soporteUrl,
    );
  }
}
