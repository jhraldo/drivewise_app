import 'dart:convert';

import 'package:http/http.dart' as http;

import 'nhtsa_service.dart';

// Servicio que consulta el resumen de un artículo de Wikipedia.
// No pide clave. Wikimedia sí pide identificar la aplicación con el
// encabezado User-Agent; sin él, las peticiones tienen límites más bajos.
class WikipediaService {
  static const Duration _tiempoMaximo = Duration(seconds: 5);

  static const Map<String, String> encabezados = {
    'User-Agent':
        'DriveWise/1.0 (proyecto academico IUE; https://github.com/jhraldo/drivewise_app)',
  };

  // Ejemplo: https://en.wikipedia.org/api/rest_v1/page/summary/Honda_Pilot
  Future<Map<String, dynamic>> obtenerResumen(String titulo) async {
    final tituloUrl = Uri.encodeComponent(titulo.trim().replaceAll(' ', '_'));

    final url = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/$tituloUrl',
    );

    final respuesta = await http
        .get(url, headers: encabezados)
        .timeout(_tiempoMaximo);

    if (respuesta.statusCode != 200) {
      throw EstadoHttpException(respuesta.statusCode);
    }

    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }
}
