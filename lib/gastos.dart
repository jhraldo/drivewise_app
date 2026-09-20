import 'package:flutter/material.dart';
import 'nuevo_gasto.dart';

class Gasto {
  final String categoria;
  final String descripcion;
  final DateTime fecha;
  final String kilometraje;
  final double valor;
  final String proveedor;
  final String notas;

  Gasto({
    required this.categoria,
    required this.descripcion,
    required this.fecha,
    required this.kilometraje,
    required this.valor,
    required this.proveedor,
    required this.notas,
  });
}

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  final List<Gasto> gastos = [
    Gasto(
      categoria: 'Aceite',
      descripcion: 'Cambio de aceite',
      fecha: DateTime(2026, 8, 15),
      kilometraje: '42.000',
      valor: 45000,
      proveedor: 'Lubricentro ABC',
      notas: 'Cambio de aceite y filtro',
    ),
    Gasto(
      categoria: 'Llantas',
      descripcion: 'Cambio de llantas',
      fecha: DateTime(2026, 7, 20),
      kilometraje: '40.500',
      valor: 320000,
      proveedor: 'Tires Center',
      notas: '',
    ),
    Gasto(
      categoria: 'Combustible',
      descripcion: 'Tanque de combustible',
      fecha: DateTime(2026, 8, 25),
      kilometraje: '42.580',
      valor: 80000,
      proveedor: 'Terpel',
      notas: '',
    ),
    Gasto(
      categoria: 'Mantenimiento',
      descripcion: 'Revisión general',
      fecha: DateTime(2026, 8, 10),
      kilometraje: '41.900',
      valor: 60000,
      proveedor: 'Taller DriveWise',
      notas: 'Revisión preventiva',
    ),
  ];

  double get totalGastado {
    return gastos.fold(
      0,
      (total, gasto) => total + gasto.valor,
    );
  }

  String formatoPesos(double valor) {
    return '\$${valor.toStringAsFixed(0)}';
  }

  Future<void> agregarGasto() async {
    final nuevoGasto = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(
        builder: (context) => const NuevoGastoPage(),
      ),
    );

    if (nuevoGasto != null) {
      setState(() {
        gastos.insert(0, nuevoGasto);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: agregarGasto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 40,
                    ),

                    const SizedBox(width: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total gastado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          formatoPesos(totalGastado),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historial de gastos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              itemCount: gastos.length,
              itemBuilder: (context, index) {
                final gasto = gastos[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        iconoCategoria(gasto.categoria),
                      ),
                    ),

                    title: Text(
                      gasto.descripcion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      '${gasto.categoria} • ${gasto.proveedor}',
                    ),

                    trailing: Text(
                      formatoPesos(gasto.valor),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData iconoCategoria(String categoria) {
    switch (categoria) {
      case 'Aceite':
        return Icons.oil_barrel_outlined;

      case 'Llantas':
        return Icons.tire_repair;

      case 'Combustible':
        return Icons.local_gas_station_outlined;

      case 'Reparaciones':
        return Icons.build_outlined;

      case 'Repuestos':
        return Icons.settings_outlined;

      case 'Mantenimiento':
        return Icons.car_repair;

      default:
        return Icons.receipt_long_outlined;
    }
  }
}