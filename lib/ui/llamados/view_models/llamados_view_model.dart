import 'package:flutter/foundation.dart';

import '../../../data/repositories/datos_exception.dart';
import '../../../data/repositories/llamados_repository.dart';
import '../../../domain/models/llamado_revision.dart';

// Estado de la pantalla de llamados a revisión de un vehículo.
class LlamadosViewModel extends ChangeNotifier {
  final LlamadosRepository _repository;
  final String marca;
  final String modelo;
  final int anio;

  LlamadosViewModel(
    this._repository, {
    required this.marca,
    required this.modelo,
    required this.anio,
  });

  // Estado público que lee la pantalla.
  List<LlamadoRevision> llamados = [];
  bool cargando = false;
  String? error;

  // NHTSA no conoce el vehículo: no es un error, se muestra como "sin información".
  bool sinInformacion = false;

  bool _cerrado = false;

  // Se llama al abrir la pantalla y cada vez que el usuario toca "Reintentar".
  Future<void> cargar() async {
    cargando = true;
    error = null;
    sinInformacion = false;
    _notificar();

    try {
      llamados = await _repository.buscarLlamados(
        marca: marca,
        modelo: modelo,
        anio: anio,
      );
    } on DatosException catch (e) {
      llamados = [];
      if (e.codigo == 'no-encontrado') {
        sinInformacion = true;
      } else {
        error = _mensajeDe(e.codigo);
      }
    }

    cargando = false;
    _notificar();
  }

  String _mensajeDe(String codigo) {
    switch (codigo) {
      case 'tiempo':
        return 'NHTSA tardó demasiado en responder. Inténtalo de nuevo.';
      case 'sin-conexion':
        return 'No hay conexión a internet. Revisa tu red e inténtalo de nuevo.';
      case 'servidor':
        return 'El servicio de NHTSA no está disponible en este momento.';
      case 'formato':
        return 'NHTSA respondió con datos que no pudimos leer.';
      default:
        return 'Ocurrió un error al consultar los llamados a revisión.';
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
