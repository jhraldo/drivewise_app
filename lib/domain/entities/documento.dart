
import 'dart:typed_data';

class Documento {
  const Documento({
    required this.id,
    required this.vehiculoId,
    this.tipo = '',
    this.numero = '',
    required this.fechaExpedicion,
    this.tieneFechaExpedicion = true,
    this.fechaVencimiento,
    this.soporteUrl,
    this.soporteLocalPath,
    this.soporteBytes,
    this.soporteNombre,
    this.soporteMimeType,
  });

  final String id;
  final String vehiculoId;

  final String tipo;
  final String numero;

  // Se conserva como DateTime para mantener compatibilidad
  // con los componentes existentes.
  final DateTime fechaExpedicion;

  // Indica si la fecha fue proporcionada por el usuario.
  // Los documentos antiguos conservan el valor true.
  final bool tieneFechaExpedicion;

  final DateTime? fechaVencimiento;

  final String? soporteUrl;
  final String? soporteLocalPath;
  final Uint8List? soporteBytes;
  final String? soporteNombre;
  final String? soporteMimeType;

  String get estado {
    if (fechaVencimiento == null) return 'Sin vencimiento';

    final hoy = DateTime.now();
    final vencimiento = fechaVencimiento!;

    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final vencimientoSinHora = DateTime(
      vencimiento.year,
      vencimiento.month,
      vencimiento.day,
    );

    return vencimientoSinHora.isBefore(hoySinHora)
        ? 'Vencido'
        : 'Vigente';
  }
}
