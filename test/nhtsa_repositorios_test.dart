import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:drivewise_app/data/repositories/catalogo_repository.dart';
import 'package:drivewise_app/data/repositories/datos_exception.dart';
import 'package:drivewise_app/data/repositories/llamados_repository.dart';
import 'package:drivewise_app/data/services/nhtsa_service.dart';

// Servicio falso: devuelve un JSON fijo o lanza el error indicado, sin usar la red.
class ServicioFalso implements NhtsaService {
  Map<String, dynamic> respuesta = {};
  Object? errorALanzar;

  Future<Map<String, dynamic>> _responder() async {
    if (errorALanzar != null) throw errorALanzar!;
    return respuesta;
  }

  @override
  Future<Map<String, dynamic>> obtenerModelos({
    required String marca,
    required int anio,
    required bool esMotocicleta,
  }) =>
      _responder();

  @override
  Future<Map<String, dynamic>> obtenerLlamados({
    required String marca,
    required String modelo,
    required int anio,
  }) =>
      _responder();
}

void main() {
  late ServicioFalso servicio;

  setUp(() {
    servicio = ServicioFalso();
  });

  test('el catálogo quita modelos repetidos y los ordena', () async {
    servicio.respuesta = {
      'Count': 3,
      'Results': [
        {'Make_ID': 1, 'Make_Name': 'MAZDA', 'Model_ID': 2, 'Model_Name': 'Mazda3'},
        {'Make_ID': 1, 'Make_Name': 'MAZDA', 'Model_ID': 3, 'Model_Name': 'CX-5'},
        {'Make_ID': 1, 'Make_Name': 'MAZDA', 'Model_ID': 4, 'Model_Name': 'CX-5'},
      ],
    };

    final modelos = await CatalogoRepository(servicio).buscarModelos(
      marca: 'mazda',
      anio: 2020,
      esMotocicleta: false,
    );

    expect(modelos.map((m) => m.nombre).toList(), ['CX-5', 'Mazda3']);
  });

  test('los llamados se leen de "results" en minúscula', () async {
    servicio.respuesta = {
      'Count': 1,
      'results': [
        {'NHTSACampaignNumber': '23V735000', 'Component': 'STEERING'},
      ],
    };

    final llamados = await LlamadosRepository(servicio).buscarLlamados(
      marca: 'honda',
      modelo: 'pilot',
      anio: 2023,
    );

    expect(llamados.length, 1);
    expect(llamados.first.numeroCampania, '23V735000');
  });

  group('proteger convierte los errores', () {
    Future<String> codigoDe(Object error) async {
      servicio.errorALanzar = error;
      try {
        await LlamadosRepository(servicio).buscarLlamados(
          marca: 'honda',
          modelo: 'pilot',
          anio: 2023,
        );
      } on DatosException catch (e) {
        return e.codigo;
      }
      return 'sin error';
    }

    test('tiempo agotado', () async {
      expect(await codigoDe(TimeoutException('lento')), 'tiempo');
    });

    test('sin conexión', () async {
      expect(await codigoDe(const SocketException('sin red')), 'sin-conexion');
    });

    test('400 significa vehículo no encontrado', () async {
      expect(await codigoDe(const EstadoHttpException(400)), 'no-encontrado');
    });

    test('500 es error del servidor', () async {
      expect(await codigoDe(const EstadoHttpException(500)), 'servidor');
    });

    test('JSON mal formado', () async {
      expect(await codigoDe(const FormatException('json roto')), 'formato');
    });
  });
}
