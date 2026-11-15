
class Documento {
  const Documento({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.numero,
    required this.fechaExpedicion,
    this.fechaVencimiento,
    this.soporteUrl,
  });

  final String id;
  final String vehiculoId;
  final String tipo;
  final String numero;
  final DateTime fechaExpedicion;
  final DateTime? fechaVencimiento;
  final String? soporteUrl;

  String get estado {
    if (fechaVencimiento == null) {
      return 'Sin vencimiento';
    }

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
