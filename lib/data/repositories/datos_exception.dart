import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../services/nhtsa_service.dart';

// Error de datos que entienden los ViewModels.
//
// Códigos posibles:
// - tiempo:        el servidor tardó más de lo permitido.
// - sin-conexion:  no hay internet o no se pudo llegar al servidor.
// - no-encontrado: NHTSA no tiene ese vehículo en su base de datos.
// - servidor:      el servidor respondió con un error.
// - formato:       la respuesta no tiene la forma esperada.
// - desconocido:   cualquier otro problema.
class DatosException implements Exception {
  final String codigo;

  const DatosException(this.codigo);

  @override
  String toString() => 'DatosException: $codigo';
}

// Ejecuta una operación de red y convierte cualquier error en DatosException.
// Las ramas van de la más específica a la más general.
Future<T> proteger<T>(Future<T> Function() operacion) async {
  try {
    return await operacion();
  } on TimeoutException catch (e) {
    debugPrint('NHTSA - tiempo agotado: $e');
    throw const DatosException('tiempo');
  } on SocketException catch (e) {
    // También atrapa la ClientException de http cuando envuelve un error de red.
    debugPrint('NHTSA - sin conexión: $e');
    throw const DatosException('sin-conexion');
  } on EstadoHttpException catch (e) {
    debugPrint('NHTSA - respuesta con código ${e.codigo}');
    // La API de llamados responde 400 cuando no conoce el vehículo.
    if (e.codigo == 400 || e.codigo == 404) {
      throw const DatosException('no-encontrado');
    }
    throw const DatosException('servidor');
  } on FormatException catch (e) {
    debugPrint('NHTSA - JSON con formato inválido: $e');
    throw const DatosException('formato');
  } on TypeError catch (e) {
    // Un campo obligatorio faltó o llegó con otro tipo en fromJson.
    debugPrint('NHTSA - campo inesperado en el JSON: $e');
    throw const DatosException('formato');
  } catch (e) {
    debugPrint('NHTSA - error desconocido: $e');
    throw const DatosException('desconocido');
  }
}
