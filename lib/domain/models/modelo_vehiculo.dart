// Modelo de vehículo que entrega el catálogo vPIC de NHTSA.
//
// Ejemplo de un elemento de "Results":
// {
//   "Make_ID": 473,
//   "Make_Name": "MAZDA",
//   "Model_ID": 2072,
//   "Model_Name": "CX-5"
// }
class ModeloVehiculo {
  final int idMarca;
  final String marca;
  final int idModelo;
  final String nombre;

  const ModeloVehiculo({
    required this.idMarca,
    required this.marca,
    required this.idModelo,
    required this.nombre,
  });

  factory ModeloVehiculo.fromJson(Map<String, dynamic> json) {
    return ModeloVehiculo(
      // Se lee como num para aceptar enteros y decimales.
      idMarca: (json['Make_ID'] as num).toInt(),
      marca: json['Make_Name'] as String,
      idModelo: (json['Model_ID'] as num).toInt(),
      // Sin valor por defecto: si falta el nombre, el error aparece de inmediato.
      nombre: (json['Model_Name'] as String).trim(),
    );
  }
}
