import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'gastos.dart';

class NuevoGastoPage extends StatefulWidget {
  const NuevoGastoPage({super.key});

  @override
  State<NuevoGastoPage> createState() => _NuevoGastoPageState();
}

class _NuevoGastoPageState extends State<NuevoGastoPage> {

  final formKey = GlobalKey<FormState>();

  final descripcionController = TextEditingController();
  final kilometrajeController = TextEditingController();
  final valorController = TextEditingController();
  final proveedorController = TextEditingController();
  final notasController = TextEditingController();

  final List<String> categorias = [
    'Aceite',
    'Llantas',
    'Combustible',
    'Reparaciones',
    'Repuestos',
    'Mantenimiento',
    'Otros',
  ];

  String categoriaSeleccionada = 'Aceite';
  DateTime fechaSeleccionada = DateTime.now();

  @override
  void dispose() {
    descripcionController.dispose();
    kilometrajeController.dispose();
    valorController.dispose();
    proveedorController.dispose();
    notasController.dispose();

    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (fecha == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      fechaSeleccionada = fecha;
    });
  }

  void guardarGasto() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final nuevoGasto = Gasto(
      categoria: categoriaSeleccionada,
      descripcion: descripcionController.text.trim(),
      fecha: fechaSeleccionada,
      kilometraje: int.parse(kilometrajeController.text.trim()),
      valor: double.parse(valorController.text.trim()),
      proveedor: proveedorController.text.trim(),
      notas: notasController.text.trim(),
    );

    // Se guarda el ScaffoldMessenger antes de cerrar la pantalla,
    // para poder mostrar mensajes en la pantalla de gastos.
    final messenger = ScaffoldMessenger.of(context);

    // Sin internet, Firestore guarda el gasto en la copia local y lo
    // envía cuando vuelve la conexión. El Future de add() solo termina
    // cuando el servidor confirma, por eso NO se espera aquí: así la
    // pantalla no se queda bloqueada sin conexión.
    enviarGasto(nuevoGasto, messenger);

    messenger.showSnackBar(
      const SnackBar(content: Text('Gasto registrado')),
    );

    Navigator.pop(context);
  }

  // Envía el gasto a Firestore y avisa si el servidor lo rechaza.
  Future<void> enviarGasto(
    Gasto gasto,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      await coleccionGastos().add(gasto.toMap());
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'No tienes permiso para guardar gastos. Inicia sesión.'
                : 'No se pudo guardar el gasto: ${e.code}',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al guardar el gasto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo gasto'),
      ),

      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            Text(
              'Registrar gasto',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Tipo de gasto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),

              items: categorias.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),

              onChanged: (valorSeleccionado) {
                if (valorSeleccionado != null) {
                  setState(() {
                    categoriaSeleccionada = valorSeleccionado;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Cambio de aceite',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),

              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Ingresa una descripción';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),

                child: Text(
                  '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: kilometrajeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kilometraje',
                hintText: 'Ej. 42580',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed_outlined),
              ),

              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Ingresa el kilometraje';
                }

                if (int.tryParse(valor.trim()) == null) {
                  return 'Ingresa solo números, sin puntos';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor',
                hintText: 'Ej. 45000',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),

              validator: (valorIngresado) {
                if (valorIngresado == null || valorIngresado.isEmpty) {
                  return 'Ingresa el valor';
                }

                final valor = double.tryParse(valorIngresado.trim());

                if (valor == null) {
                  return 'Ingresa un valor válido';
                }

                if (valor <= 0) {
                  return 'El valor debe ser mayor que cero';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: proveedorController,
              decoration: const InputDecoration(
                labelText: 'Lugar o proveedor',
                hintText: 'Ej. Taller Los Amigos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: notasController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas',
                hintText: 'Información adicional',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: guardarGasto,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar gasto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}