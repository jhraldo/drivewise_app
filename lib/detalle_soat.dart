import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'soat.dart';

// ============================================================
// DETALLE / REGISTRO DEL SOAT
// ============================================================
//
// Permite registrar o actualizar los datos del SOAT.
// Al guardar, regresa el Soat a la pantalla anterior.

class DetalleSoatPage extends StatefulWidget {
  const DetalleSoatPage({super.key});

  @override
  State<DetalleSoatPage> createState() => _DetalleSoatPageState();
}

class _DetalleSoatPageState extends State<DetalleSoatPage> {
  final formKey = GlobalKey<FormState>();
  final aseguradoraController = TextEditingController();
  final polizaController = TextEditingController();

  DateTime? fechaExpedicion;
  DateTime? fechaVencimiento;
  bool recordatorioActivo = true;

  bool cargando = true;
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    aseguradoraController.dispose();
    polizaController.dispose();
    super.dispose();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      errorCarga = null;
    });

    try {
      final soat = await cargarSoat();
      if (!mounted) return;

      setState(() {
        if (soat != null) {
          fechaExpedicion = soat.fechaExpedicion;
          fechaVencimiento = soat.fechaVencimiento;
          aseguradoraController.text = soat.aseguradora;
          polizaController.text = soat.numeroPoliza;
          recordatorioActivo = soat.recordatorioActivo;
        }
        cargando = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        errorCarga = 'No se pudo consultar el SOAT: ${e.code}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        errorCarga = 'Ocurrió un error al consultar el SOAT.';
      });
    }
  }

  Future<void> elegirExpedicion() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaExpedicion ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (fecha == null || !mounted) return;

    setState(() {
      fechaExpedicion = fecha;
      // Por defecto el SOAT dura un año.
      fechaVencimiento ??= DateTime(fecha.year + 1, fecha.month, fecha.day);
    });
  }

  Future<void> elegirVencimiento() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaVencimiento ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2040),
    );
    if (fecha == null || !mounted) return;

    setState(() => fechaVencimiento = fecha);
  }

  void guardar() {
    if (!formKey.currentState!.validate()) return;

    if (fechaExpedicion == null || fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las dos fechas del SOAT')),
      );
      return;
    }

    if (!fechaVencimiento!.isAfter(fechaExpedicion!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de vencimiento debe ser posterior a la de expedición',
          ),
        ),
      );
      return;
    }

    final soat = Soat(
      fechaExpedicion: fechaExpedicion!,
      fechaVencimiento: fechaVencimiento!,
      aseguradora: aseguradoraController.text.trim(),
      numeroPoliza: polizaController.text.trim(),
      recordatorioActivo: recordatorioActivo,
    );

    final messenger = ScaffoldMessenger.of(context);

    // Igual que con los gastos: no se espera al servidor para que
    // la pantalla no se bloquee sin conexión. Firestore lo envía después.
    enviar(soat, messenger);

    messenger.showSnackBar(
      const SnackBar(content: Text('SOAT guardado')),
    );

    Navigator.pop(context, soat);
  }

  Future<void> enviar(Soat soat, ScaffoldMessengerState messenger) async {
    try {
      await documentoSoat().set(soat.toMap());
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo guardar el SOAT: ${e.code}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al guardar el SOAT.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle SOAT')),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorCarga != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 12),
              Text(errorCarga!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: cargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado calculado con las fechas elegidas (aún sin guardar).
    final vista = fechaExpedicion != null && fechaVencimiento != null
        ? Soat(
            fechaExpedicion: fechaExpedicion!,
            fechaVencimiento: fechaVencimiento!,
            aseguradora: '',
            numeroPoliza: '',
            recordatorioActivo: recordatorioActivo,
          )
        : null;

    final Color colorEstado = vista == null
        ? Colors.grey
        : vista.vencido
            ? Colors.red
            : vista.porVencer
                ? Colors.orange
                : Colors.green;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.description_outlined, size: 70),
                  const SizedBox(height: 16),
                  Text(
                    'SOAT',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vista == null
                          ? 'Sin registrar'
                          : '${vista.estado} • ${vista.descripcionVencimiento}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorEstado,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          _campoFecha(
            icon: Icons.calendar_today_outlined,
            titulo: 'Fecha de expedición',
            fecha: fechaExpedicion,
            onTap: elegirExpedicion,
          ),

          const SizedBox(height: 16),

          _campoFecha(
            icon: Icons.event_outlined,
            titulo: 'Fecha de vencimiento',
            fecha: fechaVencimiento,
            onTap: elegirVencimiento,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: aseguradoraController,
            decoration: const InputDecoration(
              labelText: 'Compañía aseguradora',
              hintText: 'Ej. SURA',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business_outlined),
            ),
            validator: (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Ingresa la aseguradora';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: polizaController,
            decoration: const InputDecoration(
              labelText: 'Número de póliza',
              hintText: 'Ej. SOAT-2026-45821',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text(
                'Recordatorio de vencimiento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Te avisaremos $diasAvisoSoat días antes del vencimiento.',
              ),
              value: recordatorioActivo,
              onChanged: (valor) => setState(() => recordatorioActivo = valor),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: guardar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar SOAT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoFecha({
    required IconData icon,
    required String titulo,
    required DateTime? fecha,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        child: Text(fecha == null ? 'Seleccionar' : formatoFecha(fecha)),
      ),
    );
  }
}
