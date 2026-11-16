import 'package:flutter/foundation.dart';

import '../../../data/repositories/datos_exception.dart';
import '../../../data/repositories/imagenes_repository.dart';
import '../../../domain/models/imagen_vehiculo.dart';

// Estado de la imagen del vehículo en Mi vehículo.
// La imagen es un complemento: si no se consigue, la pantalla muestra el ícono.
class ImagenVehiculoViewModel extends ChangeNotifier {
  final ImagenesRepository _repository;
  final String marca;
  final String modelo;

  ImagenVehiculoViewModel(
    this._repository, {
    required this.marca,
    required this.modelo,
  });

  // Estado público que lee la tarjeta.
  ImagenVehiculo? imagen;
  bool cargando = false;
  bool fallo = false;

  bool _cerrado = false;

  Future<void> cargar() async {
    cargando = true;
    fallo = false;
    _notificar();

    try {
      imagen = await _repository.buscarImagen(marca: marca, modelo: modelo);
    } on DatosException catch (e) {
      imagen = null;
      // Que Wikipedia no tenga el artículo no es una falla: solo no hay foto.
      fallo = e.codigo != 'no-encontrado';
    }

    cargando = false;
    _notificar();
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
