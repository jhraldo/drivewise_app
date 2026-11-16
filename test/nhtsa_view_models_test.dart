import 'package:flutter_test/flutter_test.dart';

import 'package:drivewise_app/data/repositories/catalogo_repository.dart';
import 'package:drivewise_app/data/repositories/datos_exception.dart';
import 'package:drivewise_app/data/repositories/llamados_repository.dart';
import 'package:drivewise_app/domain/models/llamado_revision.dart';
import 'package:drivewise_app/domain/models/modelo_vehiculo.dart';
import 'package:drivewise_app/ui/catalogo/view_models/catalogo_view_model.dart';
import 'package:drivewise_app/ui/llamados/view_models/llamados_view_model.dart';

// Repositorios falsos con implements: permiten probar sin red.
class CatalogoFalso implements CatalogoRepository {
  List<ModeloVehiculo> modelos = [];
  DatosException? error;

  @override
  Future<List<ModeloVehiculo>> buscarModelos({
    required String marca,
    required int anio,
    required bool esMotocicleta,
  }) async {
    if (error != null) throw error!;
    return modelos;
  }
}

class LlamadosFalso implements LlamadosRepository {
  List<LlamadoRevision> llamados = [];
  DatosException? error;

  @override
  Future<List<LlamadoRevision>> buscarLlamados({
    required String marca,
    required String modelo,
    required int anio,
  }) async {
    if (error != null) throw error!;
    return llamados;
  }
}

void main() {
  group('CatalogoViewModel', () {
    late CatalogoFalso repositorio;
    late CatalogoViewModel viewModel;

    setUp(() {
      repositorio = CatalogoFalso();
      viewModel = CatalogoViewModel(
        repositorio,
        marca: 'Mazda',
        anio: 2020,
        esMotocicleta: false,
      );
    });

    tearDown(() => viewModel.dispose());

    test('carga los modelos', () async {
      repositorio.modelos = const [
        ModeloVehiculo(idMarca: 1, marca: 'MAZDA', idModelo: 2, nombre: 'CX-5'),
      ];

      await viewModel.cargar();

      expect(viewModel.cargando, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.modelos.length, 1);
    });

    test('muestra un mensaje sin conexión y se recupera al reintentar', () async {
      repositorio.error = const DatosException('sin-conexion');
      await viewModel.cargar();
      expect(viewModel.error, contains('conexión'));

      // El usuario recupera la red y toca "Reintentar".
      repositorio.error = null;
      repositorio.modelos = const [
        ModeloVehiculo(idMarca: 1, marca: 'MAZDA', idModelo: 2, nombre: 'CX-5'),
      ];
      await viewModel.cargar();

      expect(viewModel.error, isNull);
      expect(viewModel.modelos.length, 1);
    });
  });

  group('LlamadosViewModel', () {
    late LlamadosFalso repositorio;
    late LlamadosViewModel viewModel;

    setUp(() {
      repositorio = LlamadosFalso();
      viewModel = LlamadosViewModel(
        repositorio,
        marca: 'Honda',
        modelo: 'Pilot',
        anio: 2023,
      );
    });

    tearDown(() => viewModel.dispose());

    test('un vehículo desconocido no se trata como error', () async {
      repositorio.error = const DatosException('no-encontrado');

      await viewModel.cargar();

      expect(viewModel.sinInformacion, isTrue);
      expect(viewModel.error, isNull);
    });

    test('el tiempo agotado muestra un mensaje de error', () async {
      repositorio.error = const DatosException('tiempo');

      await viewModel.cargar();

      expect(viewModel.error, contains('tardó'));
      expect(viewModel.llamados, isEmpty);
    });

    test('carga los llamados', () async {
      repositorio.llamados = const [
        LlamadoRevision(
          numeroCampania: '23V735000',
          fabricante: 'Honda',
          fechaReporte: '02/11/2023',
          componente: 'STEERING',
          resumen: '',
          consecuencia: '',
          solucion: '',
        ),
      ];

      await viewModel.cargar();

      expect(viewModel.llamados.single.numeroCampania, '23V735000');
      expect(viewModel.sinInformacion, isFalse);
    });
  });
}
