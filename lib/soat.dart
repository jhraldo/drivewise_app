import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'avisos.dart';

// ============================================================
// MODELO DEL SOAT
// ============================================================
//
// Se guarda en Firestore en el documento:
// usuarios/{uid}/documentos/soat

// Días antes del vencimiento en que se empieza a mostrar la alerta.
const int diasAvisoSoat = 30;

class Soat {
  final DateTime fechaExpedicion;
  final DateTime fechaVencimiento;
  final String aseguradora;
  final String numeroPoliza;
  final bool recordatorioActivo;

  Soat({
    required this.fechaExpedicion,
    required this.fechaVencimiento,
    required this.aseguradora,
    required this.numeroPoliza,
    required this.recordatorioActivo,
  });

  Map<String, dynamic> toMap() {
    return {
      'fechaExpedicion': Timestamp.fromDate(fechaExpedicion),
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
      'aseguradora': aseguradora,
      'numeroPoliza': numeroPoliza,
      'recordatorioActivo': recordatorioActivo,
    };
  }

  factory Soat.fromMap(Map<String, dynamic> d) {
    return Soat(
      fechaExpedicion:
          (d['fechaExpedicion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaVencimiento:
          (d['fechaVencimiento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      aseguradora: d['aseguradora'] as String? ?? '',
      numeroPoliza: d['numeroPoliza'] as String? ?? '',
      recordatorioActivo: d['recordatorioActivo'] as bool? ?? true,
    );
  }

  // Días que faltan para el vencimiento.
  // Negativo si ya venció, 0 si vence hoy.
  int get diasParaVencer {
    final hoy = DateTime.now();
    final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final soloVence = DateTime(
      fechaVencimiento.year,
      fechaVencimiento.month,
      fechaVencimiento.day,
    );
    return soloVence.difference(soloHoy).inDays;
  }

  bool get vencido => diasParaVencer < 0;

  bool get porVencer => !vencido && diasParaVencer <= diasAvisoSoat;

  String get estado {
    if (vencido) return 'Vencido';
    if (porVencer) return 'Por vencer';
    return 'Vigente';
  }

  // Texto corto para la tarjeta de recordatorios.
  String get descripcionVencimiento {
    final dias = diasParaVencer;
    if (dias < 0) return 'Venció hace ${-dias} ${-dias == 1 ? 'día' : 'días'}';
    if (dias == 0) return 'Vence hoy';
    return 'Vence en $dias ${dias == 1 ? 'día' : 'días'}';
  }
}

String formatoFecha(DateTime fecha) {
  return '${fecha.day}/${fecha.month}/${fecha.year}';
}

// ============================================================
// ACCESO A FIRESTORE
// ============================================================

DocumentReference<Map<String, dynamic>> documentoSoat() {
  final usuario = FirebaseAuth.instance.currentUser;

  if (usuario == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(usuario.uid)
      .collection('documentos')
      .doc('soat');
}

// Devuelve el SOAT guardado, o null si el usuario aún no lo registra.
// Sin conexión, Firestore responde con la copia local.
Future<Soat?> cargarSoat() async {
  final doc = await documentoSoat().get();
  final datos = doc.data();
  if (!doc.exists || datos == null) return null;
  return Soat.fromMap(datos);
}

// ============================================================
// ALERTA EMERGENTE (POP-UP)
// ============================================================

// Muestra un AlertDialog si el SOAT está vencido o vence pronto
// y el recordatorio está activado. Si no hay nada que avisar, no hace nada.
Future<void> mostrarAlertaSoat(BuildContext context, Soat soat) async {
  if (!soat.recordatorioActivo) return;
  if (!soat.vencido && !soat.porVencer) return;

  final dias = soat.diasParaVencer;
  final String mensaje;

  if (dias < 0) {
    mensaje =
        'Tu SOAT venció el ${formatoFecha(soat.fechaVencimiento)}, hace ${-dias} '
        '${-dias == 1 ? 'día' : 'días'}. Circular sin SOAT vigente genera multa '
        'e inmovilización del vehículo. Renuévalo cuanto antes.';
  } else if (dias == 0) {
    mensaje = 'Tu SOAT vence HOY (${formatoFecha(soat.fechaVencimiento)}). '
        'Renuévalo para evitar multas.';
  } else {
    mensaje =
        'Tu SOAT vence en $dias ${dias == 1 ? 'día' : 'días'}, el '
        '${formatoFecha(soat.fechaVencimiento)}. Recuerda renovarlo a tiempo.';
  }

  final titulo = soat.vencido ? 'SOAT vencido' : 'SOAT por vencer';

  // 1. Notificación local en la barra del teléfono.
  try {
    await avisarSoat(titulo, mensaje);
  } catch (_) {
    // Si falla (por ejemplo, sin permiso), se sigue con el pop-up.
  }

  if (!context.mounted) return;

  // 2. Alerta emergente dentro de la app.
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Icon(
          soat.vencido ? Icons.error_outline : Icons.warning_amber_rounded,
          color: soat.vencido ? Colors.red : Colors.orange,
          size: 48,
        ),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      );
    },
  );
}

// Carga el SOAT y, si hace falta, muestra la alerta.
// Los errores se ignoran: la alerta es un aviso, no debe romper la pantalla.
Future<void> revisarVencimientoSoat(BuildContext context) async {
  try {
    final soat = await cargarSoat();
    if (soat == null || !context.mounted) return;
    await mostrarAlertaSoat(context, soat);
  } catch (_) {
    // Sin sesión o sin datos: no se muestra nada.
  }
}
