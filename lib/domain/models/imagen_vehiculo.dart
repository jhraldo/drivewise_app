// Imagen y descripción de un modelo, tomadas del resumen de Wikipedia.
//
// Campos usados de la respuesta de /page/summary/{titulo}:
// {
//   "type": "standard",
//   "title": "Honda Pilot",
//   "description": "Mid-size crossover SUV",
//   "thumbnail": { "source": "https://...330px-2025_Honda_Pilot.jpg", ... }
// }
class ImagenVehiculo {
  final String titulo;
  final String descripcion;
  final String urlImagen;

  const ImagenVehiculo({
    required this.titulo,
    required this.descripcion,
    required this.urlImagen,
  });

  // Devuelve null cuando el artículo no sirve como imagen del modelo:
  // no tiene foto o es una página de desambiguación.
  static ImagenVehiculo? desdeJson(Map<String, dynamic> json) {
    if (json['type'] != 'standard') return null;

    final miniatura = json['thumbnail'] as Map<String, dynamic>?;
    if (miniatura == null) return null;

    return ImagenVehiculo(
      titulo: json['title'] as String,
      descripcion: json['description'] as String? ?? '',
      urlImagen: miniatura['source'] as String,
    );
  }
}
