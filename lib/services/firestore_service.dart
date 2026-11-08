
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Instancia de Firebase Firestore.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar un documento nuevo.
  Future<DocumentReference<Map<String, dynamic>>> agregar(
    String coleccion,
    Map<String, dynamic> datos,
  ) async {
    return await _db.collection(coleccion).add(datos);
  }

  // Obtener todos los documentos de una colección.
  Future<QuerySnapshot<Map<String, dynamic>>> obtenerTodos(
    String coleccion,
  ) async {
    return await _db.collection(coleccion).get();
  }

  // Obtener un documento por su ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> obtenerPorId(
    String coleccion,
    String id,
  ) async {
    return await _db.collection(coleccion).doc(id).get();
  }

  // Actualizar un documento existente.
  Future<void> actualizar(
    String coleccion,
    String id,
    Map<String, dynamic> datos,
  ) async {
    await _db.collection(coleccion).doc(id).update(datos);
  }

  // Eliminar un documento.
  Future<void> eliminar(
    String coleccion,
    String id,
  ) async {
    await _db.collection(coleccion).doc(id).delete();
  }
}
