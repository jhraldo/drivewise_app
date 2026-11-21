import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'detalle_soat.dart';
import 'soat.dart';

class RecordatoriosPage extends StatefulWidget {
  const RecordatoriosPage({super.key});

  @override
  State<RecordatoriosPage> createState() => _RecordatoriosPageState();
}

class _RecordatoriosPageState extends State<RecordatoriosPage> {
  Soat? soat;
  bool cargando = true;
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    cargar(mostrarAlerta: true);
  }

  Future<void> cargar({bool mostrarAlerta = false}) async {
    setState(() {
      cargando = true;
      errorCarga = null;
    });

    try {
      final resultado = await cargarSoat();
      if (!mounted) return;

      setState(() {
        soat = resultado;
        cargando = false;
      });

      // Pop-up de alerta según la fecha de vencimiento.
      if (mostrarAlerta && resultado != null) {
        await mostrarAlertaSoat(context, resultado);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        errorCarga = 'No se pudieron consultar los recordatorios: ${e.code}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
        errorCarga = 'Ocurrió un error al consultar los recordatorios.';
      });
    }
  }

  Future<void> abrirSoat() async {
    final guardado = await Navigator.push<Soat>(
      context,
      MaterialPageRoute(builder: (context) => const DetalleSoatPage()),
    );

    if (guardado == null || !mounted) return;

    // Se usa el SOAT recién guardado y se revisa si hay que avisar.
    setState(() => soat = guardado);
    await mostrarAlertaSoat(context, guardado);
  }

  Color colorSoat(Soat s) {
    if (s.vencido) return Colors.red;
    if (s.porVencer) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: RefreshIndicator(
        onRefresh: () => cargar(mostrarAlerta: true),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Próximos vencimientos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Mantente al día con los documentos y mantenimientos de tu vehículo.',
            ),
            const SizedBox(height: 24),

            _tarjetaSoat(),

            const RecordatorioCard(
              icon: Icons.fact_check_outlined,
              titulo: 'Tecnomecánica',
              descripcion: 'Próximamente',
              colorIcono: Colors.orange,
            ),
            const RecordatorioCard(
              icon: Icons.shield_outlined,
              titulo: 'Seguro',
              descripcion: 'Próximamente',
              colorIcono: Colors.blue,
            ),
            const RecordatorioCard(
              icon: Icons.oil_barrel_outlined,
              titulo: 'Cambio de aceite',
              descripcion: 'Próximamente',
              colorIcono: Colors.amber,
            ),
            const RecordatorioCard(
              icon: Icons.tire_repair,
              titulo: 'Revisión de llantas',
              descripcion: 'Próximamente',
              colorIcono: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaSoat() {
    if (cargando) {
      return const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('SOAT', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Cargando...'),
        ),
      );
    }

    if (errorCarga != null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: const Text(
            'SOAT',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(errorCarga!),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cargar(mostrarAlerta: true),
          ),
        ),
      );
    }

    final s = soat;

    if (s == null) {
      return RecordatorioCard(
        icon: Icons.description_outlined,
        titulo: 'SOAT',
        descripcion: 'Sin registrar. Toca para ingresar la fecha de vencimiento.',
        colorIcono: Colors.grey,
        onTap: abrirSoat,
      );
    }

    return RecordatorioCard(
      icon: Icons.description_outlined,
      titulo: 'SOAT • ${s.estado}',
      descripcion:
          '${s.descripcionVencimiento} (${formatoFecha(s.fechaVencimiento)})',
      colorIcono: colorSoat(s),
      onTap: abrirSoat,
    );
  }
}

class RecordatorioCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color colorIcono;
  final VoidCallback? onTap;

  const RecordatorioCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.colorIcono,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorIcono.withValues(alpha: 0.15),
          child: Icon(icon, color: colorIcono),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(descripcion),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
