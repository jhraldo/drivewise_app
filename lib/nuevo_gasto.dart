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
      descripcion: descripcionController.text,
      fecha: fechaSeleccionada,
      kilometraje: kilometrajeController.text,
      valor: double.parse(valorController.text),
      proveedor: proveedorController.text,
      notas: notasController.text,
    );

    Navigator.pop(context, nuevoGasto);
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

                final valor = double.tryParse(valorIngresado);

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