
import 'package:flutter/material.dart';
import 'gastos.dart';

class DetalleGastoPage extends StatelessWidget {
  final Gasto gasto;

  const DetalleGastoPage({
    super.key,
    required this.gasto,
  });

  String formatoPesos(double valor) {
    return '\$${valor.toStringAsFixed(0)}';
  }

  String formatoFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Widget mostrarDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valor.isEmpty ? 'No registrado' : valor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del gasto'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 55,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatoPesos(gasto.valor),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(gasto.descripcion),
                    ],
                  ),
                ),

                const Divider(height: 30),

                mostrarDato('Categoría', gasto.categoria),
                mostrarDato('Descripción', gasto.descripcion),
                mostrarDato('Fecha', formatoFecha(gasto.fecha)),
                mostrarDato('Kilometraje', gasto.kilometraje),
                mostrarDato('Valor', formatoPesos(gasto.valor)),
                mostrarDato('Proveedor', gasto.proveedor),
                mostrarDato('Notas', gasto.notas),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
