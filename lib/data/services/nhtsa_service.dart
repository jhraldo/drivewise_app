import 'dart:convert';

import 'package:http/http.dart' as http;

// Se lanza cuando el servidor responde con un código distinto de 200.
// Un 404 o un 500 no lanzan excepción por sí solos, por eso se revisa a mano.
class EstadoHttpException implements Exception {
  final int codigo;

  const EstadoHttpException(this.codigo);

  @override
  String toString() => 'EstadoHttpException: código $codigo';
}

// Servicio que habla con las APIs públicas de NHTSA.
// Devuelve el JSON tal como llega; los repositorios lo convierten en modelos.
// Ninguna de las dos APIs pide clave.
class NhtsaService {
  static const Duration _tiempoMaximo = Duration(seconds: 5);

  // Catálogo vPIC: modelos de una marca en un año.
  // Ejemplo: https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/mazda/modelyear/2020?format=json
  Future<Map<String, dynamic>> obtenerModelos({
    required String marca,
    required int anio,
    required bool esMotocicleta,
  }) async {
    final marcaUrl = Uri.encodeComponent(marca.trim());

    // Para motos se filtra por tipo. Para carros no, porque las camionetas
    // aparecen como otro tipo de vehículo y se perderían.
    final tipo = esMotocicleta ? '/vehicletype/motorcycle' : '';

    final url = Uri.parse(
      'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear'
      '/make/$marcaUrl/modelyear/$anio$tipo?format=json',
    );

    return _get(url);
  }

  // Llamados a revisión de un vehículo.
  // Ejemplo: https://api.nhtsa.gov/recalls/recallsByVehicle?make=honda&model=pilot&modelYear=2023
  Future<Map<String, dynamic>> obtenerLlamados({
    required String marca,
    required String modelo,
    required int anio,
  }) async {
    final url = Uri.parse(
      'https://api.nhtsa.gov/recalls/recallsByVehicle'
      '?make=${Uri.encodeComponent(marca.trim())}'
      '&model=${Uri.encodeComponent(modelo.trim())}'
      '&modelYear=$anio',
    );

    return _get(url);
  }

  // Petición GET común: tiempo máximo, revisión del código y conversión del JSON.
  Future<Map<String, dynamic>> _get(Uri url) async {
    final respuesta = await http.get(url).timeout(_tiempoMaximo);

    if (respuesta.statusCode != 200) {
      throw EstadoHttpException(respuesta.statusCode);
    }

    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }
}
