// Llamado a revisión (recall) que entrega la API de NHTSA.
//
// Campos usados de cada elemento de "results":
// NHTSACampaignNumber, Manufacturer, ReportReceivedDate,
// Component, Summary, Consequence y Remedy.
class LlamadoRevision {
  final String numeroCampania;
  final String fabricante;
  final String fechaReporte;
  final String componente;
  final String resumen;
  final String consecuencia;
  final String solucion;

  const LlamadoRevision({
    required this.numeroCampania,
    required this.fabricante,
    required this.fechaReporte,
    required this.componente,
    required this.resumen,
    required this.consecuencia,
    required this.solucion,
  });

  factory LlamadoRevision.fromJson(Map<String, dynamic> json) {
    return LlamadoRevision(
      // El número de campaña identifica el llamado: no lleva valor por defecto.
      numeroCampania: json['NHTSACampaignNumber'] as String,
      // Los textos descriptivos pueden faltar en algunos llamados.
      fabricante: json['Manufacturer'] as String? ?? '',
      fechaReporte: json['ReportReceivedDate'] as String? ?? '',
      componente: json['Component'] as String? ?? 'Componente no indicado',
      resumen: json['Summary'] as String? ?? '',
      consecuencia: json['Consequence'] as String? ?? '',
      solucion: json['Remedy'] as String? ?? '',
    );
  }
}
