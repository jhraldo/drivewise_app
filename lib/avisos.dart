import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================================
// NOTIFICACIONES LOCALES
// ============================================================
//
// Las crea y las muestra la propia app, sin pasar por un servidor.
// Por eso funcionan también sin internet.

final avisos = FlutterLocalNotificationsPlugin();

// Se llama una sola vez al arrancar la app (en main).
Future<void> iniciarAvisos() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await avisos.initialize(
    settings: const InitializationSettings(android: android),
  );

  // En Android 13 o superior muestra el diálogo del permiso.
  await avisos
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

// Muestra la notificación de vencimiento del SOAT.
// Se usa siempre el mismo id: un aviso nuevo reemplaza al anterior.
Future<void> avisarSoat(String titulo, String mensaje) async {
  const detalle = AndroidNotificationDetails(
    'documentos', // id del canal
    'Vencimiento de documentos', // nombre visible del canal
    channelDescription: 'Avisos de SOAT y otros documentos del vehículo',
    importance: Importance.high,
    priority: Priority.high,
  );

  await avisos.show(
    id: 1,
    title: titulo,
    body: mensaje,
    notificationDetails: const NotificationDetails(android: detalle),
  );
}
