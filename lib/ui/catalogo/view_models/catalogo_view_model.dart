import 'package:flutter/foundation.dart';

import '../../../data/repositories/catalogo_repository.dart';
import '../../../data/repositories/datos_exception.dart';
import '../../../domain/models/modelo_vehiculo.dart';

// Estado de la pantalla que busca modelos en el catálogo de NHTSA.
class CatalogoViewModel extends ChangeNotifier {
  final CatalogoRepository _repository;
  final String marca;
  final int anio;
  final bool esMotocicleta;

  CatalogoViewModel(
    this._repository, {
    required this.marca,
    required this.anio,
    required this.esMotocicleta,
  });

  // Estado público que lee la pantalla.
  List<ModeloVehiculo> modelos = [];
  bool cargando = false;
  String? error;

  bool _cerrado = false;

  // Se llama al abrir la pantalla y cada vez que el usuario toca "Reintentar".
  Future<void> cargar() async {
    cargando = true;
    error = null;
    _notificar();

    try {
      modelos = await _repository.buscarModelos(
        marca: marca,
        anio: anio,
        esMotocicleta: esMotocicleta,
      );
    } on DatosException catch (e) {
      modelos = [];
      error = _mensajeDe(e.codigo);
    }

    cargando = false;
    _notificar();
  }

  String _mensajeDe(String codigo) {
    switch (codigo) {
      case 'tiempo':
        return 'El catálogo tardó demasiado en responder. Inténtalo de nuevo.';
      case 'sin-conexion':
        return 'No hay conexión a internet. Revisa tu red e inténtalo de nuevo.';
      case 'no-encontrado':
        return 'El catálogo no tiene información para esa marca y año.';
      case 'servidor':
        return 'El catálogo no está disponible en este momento.';
      case 'formato':
        return 'El catálogo respondió con datos que no pudimos leer.';
      default:
        return 'Ocurrió un error al consultar el catálogo.';
    }
  }

  // Evita notificar si la pantalla ya se cerró mientras llegaba la respuesta.
  void _notificar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }
}
