
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/documento.dart';
import '../../domain/repositories/documento_repository.dart';
import '../datos/documento_dto.dart';

class FirestoreDocumentoRepository implements DocumentoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _coleccion(
    String vehiculoId,
  ) {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw StateError('No hay una sesión iniciada.');
    }

    return _db
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('vehiculos')
        .doc(vehiculoId)
        .collection('documentos');
  }

  @override
  Future<List<Documento>> obtenerPorVehiculo(String vehiculoId) async {
    final consulta = await _coleccion(vehiculoId).get();

    return consulta.docs
        .map((doc) => DocumentoDto.desdeFirestore(doc, vehiculoId).aEntidad())
        .toList();
  }

  @override
  Future<void> guardar(Documento documento) async {
    await _coleccion(documento.vehiculoId)
        .doc(documento.id)
        .set({
      'tipo': documento.tipo,
      'numero': documento.numero,
      'fechaExpedicion': Timestamp.fromDate(documento.fechaExpedicion),
      'fechaVencimiento': documento.fechaVencimiento == null
          ? null
          : Timestamp.fromDate(documento.fechaVencimiento!),
      'soporteUrl': documento.soporteUrl,
    });
  }

  @override
  Future<void> actualizar(Documento documento) async {
    await _coleccion(documento.vehiculoId)
        .doc(documento.id)
        .update({
      'tipo': documento.tipo,
      'numero': documento.numero,
      'fechaExpedicion': Timestamp.fromDate(documento.fechaExpedicion),
      'fechaVencimiento': documento.fechaVencimiento == null
          ? null
          : Timestamp.fromDate(documento.fechaVencimiento!),
      'soporteUrl': documento.soporteUrl,
    });
  }

  @override
  Future<void> eliminar(String documentoId, String vehiculoId) async {
    await _coleccion(vehiculoId).doc(documentoId).delete();
  }
}
