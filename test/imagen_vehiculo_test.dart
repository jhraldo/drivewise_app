import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:drivewise_app/data/repositories/imagenes_repository.dart';
import 'package:drivewise_app/data/services/nhtsa_service.dart';
import 'package:drivewise_app/data/services/wikipedia_service.dart';
import 'package:drivewise_app/domain/models/imagen_vehiculo.dart';
import 'package:drivewise_app/ui/vehiculo/view_models/imagen_vehiculo_view_model.dart';

// Respuesta real (recortada) de /page/summary/Honda_Pilot.
const Map<String, dynamic> resumenPilot = {
  'type': 'standard',
  'title': 'Honda Pilot',
  'description': 'Mid-size crossover SUV',
  'thumbnail': {
    'source': 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/'
        '2025_Honda_Pilot.jpg/330px-2025_Honda_Pilot.jpg',
    'width': 330,
    'height': 248,
  },
};

// Servicio falso: guarda el título pedido y responde sin usar la red.
class WikipediaFalso implements WikipediaService {
  Map<String, dynamic> respuesta = resumenPilot;
  Object? errorALanzar;
  String? tituloPedido;

  @override
  Future<Map<String, dynamic>> obtenerResumen(String titulo) async {
    tituloPedido = titulo;
    if (errorALanzar != null) throw errorALanzar!;
    return respuesta;
  }
}

void main() {
  group('ImagenVehiculo.desdeJson', () {
    test('toma la miniatura y la descripción', () {
      final imagen = ImagenVehiculo.desdeJson(resumenPilot)!;

      expect(imagen.titulo, 'Honda Pilot');
      expect(imagen.descripcion, 'Mid-size crossover SUV');
      expect(imagen.urlImagen, endsWith('330px-2025_Honda_Pilot.jpg'));
    });

    test('devuelve null si el artículo no tiene foto', () {
      expect(
        ImagenVehiculo.desdeJson({'type': 'standard', 'title': 'Sin foto'}),
        isNull,
      );
    });

    test('devuelve null si es una página de desambiguación', () {
      expect(
        ImagenVehiculo.desdeJson({
          'type': 'disambiguation',
          'title': 'Pilot',
          'thumbnail': {'source': 'https://ejemplo.org/foto.jpg'},
        }),
        isNull,
      );
    });
  });

  group('ImagenesRepository', () {
    test('pide el artículo "Marca Modelo"', () async {
      final servicio = WikipediaFalso();

      final imagen = await ImagenesRepository(servicio)
          .buscarImagen(marca: 'Honda', modelo: 'Pilot');

      expect(servicio.tituloPedido, 'Honda Pilot');
      expect(imagen, isNotNull);
    });
  });

  group('ImagenVehiculoViewModel', () {
    late WikipediaFalso servicio;
    late ImagenVehiculoViewModel viewModel;

    setUp(() {
      servicio = WikipediaFalso();
      viewModel = ImagenVehiculoViewModel(
        ImagenesRepository(servicio),
        marca: 'Honda',
        modelo: 'Pilot',
      );
    });

    tearDown(() => viewModel.dispose());

    test('carga la imagen', () async {
      await viewModel.cargar();

      expect(viewModel.imagen, isNotNull);
      expect(viewModel.fallo, isFalse);
    });

    test('un artículo inexistente no se marca como falla', () async {
      servicio.errorALanzar = const EstadoHttpException(404);

      await viewModel.cargar();

      expect(viewModel.imagen, isNull);
      expect(viewModel.fallo, isFalse);
    });

    test('sin conexión se marca como falla para poder reintentar', () async {
      servicio.errorALanzar = const SocketException('sin red');

      await viewModel.cargar();

      expect(viewModel.imagen, isNull);
      expect(viewModel.fallo, isTrue);
    });
  });
}
