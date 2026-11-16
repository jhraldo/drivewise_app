import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'mantenimiento.dart';

// ============================================================
// MODELO DEL VEHICULO
// ============================================================

class Vehiculo {
  final String id;
  final String tipo;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String color;
  final int kilometraje;
  final String cilindraje;
  final String combustible;
  final String transmision;
  final String ciudad;

  Vehiculo({
    this.id = '',
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.color,
    required this.kilometraje,
    required this.cilindraje,
    required this.combustible,
    required this.transmision,
    required this.ciudad,
  });

  // Convertir el objeto Vehiculo en un mapa para Firestore.
  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      'color': color,
      'kilometraje': kilometraje,
      'cilindraje': cilindraje,
      'combustible': combustible,
      'transmision': transmision,
      'ciudad': ciudad,
      'fechaRegistro': FieldValue.serverTimestamp(),
    };
  }

  // Crear un objeto Vehiculo a partir de los datos de Firestore.
  factory Vehiculo.fromMap(
    String id,
    Map<String, dynamic> datos,
  ) {
    return Vehiculo(
      id: id,
      tipo: datos['tipo'] ?? '',
      marca: datos['marca'] ?? '',
      modelo: datos['modelo'] ?? '',
      anio: (datos['anio'] as num?)?.toInt() ?? 0,
      placa: datos['placa'] ?? '',
      color: datos['color'] ?? '',
      kilometraje: (datos['kilometraje'] as num?)?.toInt() ?? 0,
      cilindraje: datos['cilindraje'] ?? '',
      combustible: datos['combustible'] ?? '',
      transmision: datos['transmision'] ?? '',
      ciudad: datos['ciudad'] ?? '',
    );
  }
}

// ============================================================
// PANTALLA PRINCIPAL: MI VEHICULO
// ============================================================

class MiVehiculoPage extends StatefulWidget {
  const MiVehiculoPage({super.key});

  @override
  State<MiVehiculoPage> createState() => _MiVehiculoPageState();
}

class _MiVehiculoPageState extends State<MiVehiculoPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Vehiculo> vehiculos = [];

  int vehiculoSeleccionado = 0;

  bool cargando = true;

  String? errorCarga;

  // Obtener la colección de vehículos del usuario autenticado.
  CollectionReference<Map<String, dynamic>> get _coleccionVehiculos {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return _db
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('vehiculos');
  }

  @override
  void initState() {
    super.initState();
    cargarVehiculos();
  }

  // ============================================================
  // CONSULTAR VEHICULOS EN FIRESTORE
  // ============================================================

  Future<void> cargarVehiculos() async {
    try {
      setState(() {
        cargando = true;
        errorCarga = null;
      });

      final consulta = await _coleccionVehiculos.get();

      final List<Vehiculo> lista = consulta.docs.map((documento) {
        return Vehiculo.fromMap(
          documento.id,
          documento.data(),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        vehiculos = lista;
        vehiculoSeleccionado = 0;
        cargando = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        errorCarga = e.message ?? 'No se pudieron consultar los vehículos.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        errorCarga = 'Ocurrió un error al consultar los vehículos.';
      });
    }
  }

  // ============================================================
  // REGISTRAR VEHICULO
  // ============================================================

  Future<void> registrarVehiculo() async {
    final resultado = await Navigator.push<Vehiculo>(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroVehiculoPage(),
      ),
    );

    if (resultado == null) {
      return;
    }

    // El formulario ya guarda el vehículo en Firestore.
    // Aquí solamente actualizamos la información de la pantalla.
    await cargarVehiculos();

    if (!mounted) return;

    final indice = vehiculos.indexWhere(
      (vehiculo) => vehiculo.id == resultado.id,
    );

    if (indice >= 0) {
      setState(() {
        vehiculoSeleccionado = indice;
      });
    }
  }

  // ============================================================
  // CONSTRUIR PANTALLA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi vehículo'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: registrarVehiculo,
        icon: const Icon(Icons.add),
        label: const Text('Agregar vehículo'),
      ),
      body: _construirContenido(colors),
    );
  }

  Widget _construirContenido(ColorScheme colors) {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorCarga != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                errorCarga!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: cargarVehiculos,
                child: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (vehiculos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 90,
                color: colors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Aún no tienes vehículos registrados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Registra tu automóvil o motocicleta para '
                'empezar a llevar el control de su información.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: registrarVehiculo,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar mi primer vehículo'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final vehiculo = vehiculos[vehiculoSeleccionado];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vehiculos.length > 1) ...[
          DropdownButtonFormField<int>(
            value: vehiculoSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Seleccionar vehículo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.directions_car),
            ),
            items: List.generate(
              vehiculos.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(
                  '${vehiculos[index].marca} '
                  '${vehiculos[index].modelo}',
                ),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  vehiculoSeleccionado = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        // TARJETA PRINCIPAL DEL VEHICULO
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  vehiculo.tipo == 'Motocicleta'
                      ? Icons.two_wheeler
                      : Icons.directions_car,
                  size: 100,
                  color: colors.primary,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehiculo.marca} ${vehiculo.modelo}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${vehiculo.anio} • ${vehiculo.color}',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _StatusBadge(
                      label: 'Registrado',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.badge,
                        size: 32,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehiculo.placa,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(vehiculo.ciudad),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.speed,
                        title: '${vehiculo.kilometraje} km',
                        subtitle: 'Kilometraje',
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.calendar_month,
                        title: '${vehiculo.anio}',
                        subtitle: 'Año del vehículo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ACCIONES RAPIDAS
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 8,
            ),
            child: Row(
              children: [
                _QuickAction(
                  icon: Icons.build,
                  label: 'Mantenimiento',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MantenimientoPage(),
                      ),
                    );
                  },
                ),
                const _QuickAction(
                  icon: Icons.local_gas_station,
                  label: 'Consumo',
                ),
                const _QuickAction(
                  icon: Icons.shield,
                  label: 'Seguro',
                ),
                const _QuickAction(
                  icon: Icons.description,
                  label: 'Documentos',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _InformationCard(
          colors: colors,
          vehiculo: vehiculo,
        ),

        const SizedBox(height: 16),

        _VehicleStatusCard(
          colors: colors,
        ),

        const SizedBox(height: 16),

        Card(
          child: ListTile(
            leading: Icon(
              Icons.route,
              color: colors.primary,
            ),
            title: const Text('Último viaje'),
            subtitle: const Text(
              'Todavía no hay información de viajes',
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ============================================================
// FORMULARIO DE REGISTRO
// ============================================================

class RegistroVehiculoPage extends StatefulWidget {
  const RegistroVehiculoPage({super.key});

  @override
  State<RegistroVehiculoPage> createState() =>
      _RegistroVehiculoPageState();
}

class _RegistroVehiculoPageState
    extends State<RegistroVehiculoPage> {

  final _formKey = GlobalKey<FormState>();

  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final placaController = TextEditingController();
  final colorController = TextEditingController();
  final kilometrajeController = TextEditingController();
  final cilindrajeController = TextEditingController();
  final ciudadController = TextEditingController();

  String tipo = 'Motocicleta';
  String combustible = 'Gasolina';
  String transmision = 'Manual';

  bool guardando = false;

  @override
  void dispose() {
    marcaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    placaController.dispose();
    colorController.dispose();
    kilometrajeController.dispose();
    cilindrajeController.dispose();
    ciudadController.dispose();

    super.dispose();
  }

  String? validarTexto(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $campo';
    }

    return null;
  }

  // ============================================================
  // GUARDAR DATOS DEL FORMULARIO
  // ============================================================

  Future<void> guardarVehiculo() async {
    if (guardando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final anio = int.tryParse(anioController.text);
    final kilometraje = int.tryParse(kilometrajeController.text);

    if (anio == null ||
        anio < 1900 ||
        anio > DateTime.now().year + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un año válido'),
        ),
      );
      return;
    }

    if (kilometraje == null || kilometraje < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un kilometraje válido'),
        ),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu sesión ha finalizado. Inicia sesión nuevamente.',
          ),
        ),
      );
      return;
    }

    final vehiculo = Vehiculo(
      tipo: tipo,
      marca: marcaController.text.trim(),
      modelo: modeloController.text.trim(),
      anio: anio,
      placa: placaController.text.trim().toUpperCase(),
      color: colorController.text.trim(),
      kilometraje: kilometraje,
      cilindraje: cilindrajeController.text.trim(),
      combustible: combustible,
      transmision: transmision,
      ciudad: ciudadController.text.trim(),
    );

    setState(() {
      guardando = true;
    });

    try {
      // Guardar directamente en la colección del usuario autenticado.
      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('vehiculos')
          .add(vehiculo.toMap());

      // Crear el objeto con el ID generado por Firestore.
      final vehiculoGuardado = Vehiculo(
        id: documento.id,
        tipo: vehiculo.tipo,
        marca: vehiculo.marca,
        modelo: vehiculo.modelo,
        anio: vehiculo.anio,
        placa: vehiculo.placa,
        color: vehiculo.color,
        kilometraje: vehiculo.kilometraje,
        cilindraje: vehiculo.cilindraje,
        combustible: vehiculo.combustible,
        transmision: vehiculo.transmision,
        ciudad: vehiculo.ciudad,
      );

      if (!mounted) return;

      Navigator.pop(context, vehiculoGuardado);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar el vehículo: ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un error al guardar el vehículo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar vehículo'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(
              Icons.directions_car,
              size: 65,
              color: colors.primary,
            ),

            const SizedBox(height: 12),

            Text(
              'Información del vehículo',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 24),

            // TIPO DE VEHICULO
            DropdownButtonFormField<String>(
              value: tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de vehículo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Motocicleta',
                  child: Text('Motocicleta'),
                ),
                DropdownMenuItem(
                  value: 'Automóvil',
                  child: Text('Automóvil'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    tipo = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // MARCA
            TextFormField(
              controller: marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca',
                hintText: 'Ej. Yamaha, Chevrolet, Mazda',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  validarTexto(value, 'la marca'),
            ),

            const SizedBox(height: 16),

            // MODELO
            TextFormField(
              controller: modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                hintText: 'Ej. FZ 2.0, Onix, Mazda 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.car_repair),
              ),
              validator: (value) =>
                  validarTexto(value, 'el modelo'),
            ),

            const SizedBox(height: 16),

            // AÑO
            TextFormField(
              controller: anioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año',
                hintText: 'Ej. 2024',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el año';
                }

                if (int.tryParse(value) == null) {
                  return 'Ingresa un año válido';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // PLACA
            TextFormField(
              controller: placaController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Placa',
                hintText: 'Ej. ABC12D',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) =>
                  validarTexto(value, 'la placa'),
            ),

            const SizedBox(height: 16),

            // COLOR
            TextFormField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                hintText: 'Ej. Negro, blanco, rojo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.palette),
              ),
              validator: (value) =>
                  validarTexto(value, 'el color'),
            ),

            const SizedBox(height: 16),

            // KILOMETRAJE
            TextFormField(
              controller: kilometrajeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kilometraje actual',
                hintText: 'Ej. 25000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el kilometraje';
                }

                if (int.tryParse(value) == null) {
                  return 'Ingresa un kilometraje válido';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // CILINDRAJE
            TextFormField(
              controller: cilindrajeController,
              decoration: const InputDecoration(
                labelText: 'Cilindraje',
                hintText: 'Ej. 149 cc o 1600 cc',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
              validator: (value) =>
                  validarTexto(value, 'el cilindraje'),
            ),

            const SizedBox(height: 16),

            // COMBUSTIBLE
            DropdownButtonFormField<String>(
              value: combustible,
              decoration: const InputDecoration(
                labelText: 'Tipo de combustible',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Gasolina',
                  child: Text('Gasolina'),
                ),
                DropdownMenuItem(
                  value: 'Diésel',
                  child: Text('Diésel'),
                ),
                DropdownMenuItem(
                  value: 'Eléctrico',
                  child: Text('Eléctrico'),
                ),
                DropdownMenuItem(
                  value: 'Híbrido',
                  child: Text('Híbrido'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    combustible = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // TRANSMISION
            DropdownButtonFormField<String>(
              value: transmision,
              decoration: const InputDecoration(
                labelText: 'Transmisión',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Manual',
                  child: Text('Manual'),
                ),
                DropdownMenuItem(
                  value: 'Automática',
                  child: Text('Automática'),
                ),
                DropdownMenuItem(
                  value: '5 velocidades',
                  child: Text('5 velocidades'),
                ),
                DropdownMenuItem(
                  value: '6 velocidades',
                  child: Text('6 velocidades'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    transmision = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // CIUDAD
            TextFormField(
              controller: ciudadController,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                hintText: 'Ej. Medellín',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) =>
                  validarTexto(value, 'la ciudad'),
            ),

            const SizedBox(height: 24),

            // BOTON GUARDAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: guardando ? null : guardarVehiculo,
                icon: guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  guardando ? 'Guardando...' : 'Guardar vehículo',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA DE INFORMACION GENERAL
// ============================================================

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.colors,
    required this.vehiculo,
  });

  final ColorScheme colors;
  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información general',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _GeneralInfo(
              title: 'Tipo de vehículo',
              value: vehiculo.tipo,
            ),

            const Divider(),

            _GeneralInfo(
              title: 'Marca',
              value: vehiculo.marca,
            ),

            const Divider(),

            _GeneralInfo(
              title: 'Modelo',
              value: vehiculo.modelo,
            ),

            const Divider(),

            _GeneralInfo(
              title: 'Cilindraje',
              value: vehiculo.cilindraje,
            ),

            const Divider(),

            _GeneralInfo(
              title: 'Combustible',
              value: vehiculo.combustible,
            ),

            const Divider(),

            _GeneralInfo(
              title: 'Transmisión',
              value: vehiculo.transmision,
            ),

            const Divider(),

            _GeneralInfo(
              title: 'Color',
              value: vehiculo.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ESTADO DEL VEHICULO
// ============================================================

class _VehicleStatusCard extends StatelessWidget {
  const _VehicleStatusCard({
    required this.colors,
  });

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado del vehículo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.build,
                    title: 'Mantenimiento',
                    status: 'Pendiente',
                    color: colors.primary,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _StatusItem(
                    icon: Icons.description,
                    title: 'Documentos',
                    status: 'Por revisar',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ETIQUETA DE ESTADO
// ============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================
// INFORMACION RAPIDA
// ============================================================

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          size: 30,
          color: colors.primary,
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACCIONES RAPIDAS
// ============================================================

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(
                icon,
                color: colors.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFORMACION GENERAL
// ============================================================

class _GeneralInfo extends StatelessWidget {
  const _GeneralInfo({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ESTADO DE LOS COMPONENTES
// ============================================================

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.title,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),

          const SizedBox(height: 6),

          Text(title),

          const SizedBox(height: 4),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}