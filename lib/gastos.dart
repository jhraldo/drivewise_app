import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'detalle_gasto.dart';
import 'nuevo_gasto.dart';

// ============================================================
// MODELO DEL GASTO
// ============================================================

class Gasto {
  final String id;
  final String categoria;
  final String descripcion;
  final DateTime fecha;
  final int kilometraje;
  final double valor;
  final String proveedor;
  final String notas;

  Gasto({
    this.id = '',
    required this.categoria,
    required this.descripcion,
    required this.fecha,
    required this.kilometraje,
    required this.valor,
    required this.proveedor,
    required this.notas,
  });

  // Convertir el gasto en un mapa para guardarlo en Firestore.
  // Firestore guarda DateTime como Timestamp.
  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      'kilometraje': kilometraje,
      'valor': valor,
      'proveedor': proveedor,
      'notas': notas,
      'fechaRegistro': FieldValue.serverTimestamp(),
    };
  }

  // Crear un gasto a partir de un documento de Firestore.
  factory Gasto.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Gasto(
      id: doc.id,
      categoria: d['categoria'] as String? ?? 'Otros',
      descripcion: d['descripcion'] as String? ?? '',
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      kilometraje: (d['kilometraje'] as num?)?.toInt() ?? 0,
      valor: (d['valor'] as num?)?.toDouble() ?? 0,
      proveedor: d['proveedor'] as String? ?? '',
      notas: d['notas'] as String? ?? '',
    );
  }
}

// Colección de gastos del usuario autenticado:
// usuarios/{uid}/gastos
CollectionReference<Map<String, dynamic>> coleccionGastos() {
  final usuario = FirebaseAuth.instance.currentUser;

  if (usuario == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(usuario.uid)
      .collection('gastos');
}

// ============================================================
// PANTALLA DE GASTOS
// ============================================================

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _gastosStream;

  @override
  void initState() {
    super.initState();
    _gastosStream = coleccionGastos().snapshots();
  }

  String formatoPesos(double valor) {
    return '\$${valor.toStringAsFixed(0)}';
  }

  void abrirNuevoGasto() {
    // La lista se actualiza sola gracias a snapshots(),
    // por eso no hace falta recibir nada al volver.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NuevoGastoPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirNuevoGasto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _gastosStream,
        builder: (context, snap) {
          // Estado de error.
          if (snap.hasError) {
            return _mensajeEstado(
              icono: Icons.error_outline,
              titulo: 'No pudimos cargar tus gastos',
              descripcion: 'Revisa tu conexión e inténtalo nuevamente.',
              accion: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _gastosStream = coleccionGastos().snapshots();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            );
          }

          // Estado de carga.
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final datos = snap.data!;

          // Ordenar del más reciente al más antiguo.
          final documentos = [...datos.docs];
          documentos.sort((a, b) {
            return Gasto.fromDoc(b).fecha.compareTo(Gasto.fromDoc(a).fecha);
          });

          final totalGastado = documentos.fold<double>(
            0,
            (total, doc) => total + Gasto.fromDoc(doc).valor,
          );

          return Column(
            children: [
              // Aviso cuando los datos vienen de la copia local.
              if (datos.metadata.isFromCache)
                Container(
                  width: double.infinity,
                  color: Colors.amber.withValues(alpha: 0.25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sin conexión: mostrando los datos guardados en el teléfono.',
                        ),
                      ),
                    ],
                  ),
                ),

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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatoPesos(totalGastado),
                              style: Theme.of(context).textTheme.headlineSmall,
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
                child: documentos.isEmpty
                    // Estado vacío.
                    ? _mensajeEstado(
                        icono: Icons.receipt_long_outlined,
                        titulo: 'Aún no tienes gastos registrados',
                        descripcion:
                            'Toca "Nuevo gasto" para registrar el primero.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: documentos.length,
                        itemBuilder: (context, index) {
                          final doc = documentos[index];
                          return _filaGasto(doc);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filaGasto(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final gasto = Gasto.fromDoc(doc);

    // hasPendingWrites es true mientras el gasto no llega al servidor.
    final sinEnviar = doc.metadata.hasPendingWrites;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleGastoPage(gasto: gasto),
            ),
          );
        },
        leading: CircleAvatar(
          child: Icon(iconoCategoria(gasto.categoria)),
        ),
        title: Text(
          gasto.descripcion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          sinEnviar
              ? '${gasto.categoria} • ${gasto.proveedor} (sin enviar)'
              : '${gasto.categoria} • ${gasto.proveedor}',
        ),
        trailing: Text(
          formatoPesos(gasto.valor),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _mensajeEstado({
    required IconData icono,
    required String titulo,
    required String descripcion,
    Widget? accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(descripcion, textAlign: TextAlign.center),
            if (accion != null) ...[
              const SizedBox(height: 12),
              accion,
            ],
          ],
        ),
      ),
    );
  }
}
