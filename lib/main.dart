import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'gastos.dart';

import 'recordatorios.dart';

import 'login.dart';

import 'mi_vehiculo.dart';

import 'widgets/reminder_card.dart';

import 'widgets/summary_card.dart';

import 'widgets/vehicle_status_row.dart';

import 'mantenimiento.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(

  ThemeMode.light,

);

class MainApp extends StatelessWidget {

  const MainApp({super.key});

  void _cambiarTema(bool temaOscuro) {

    themeNotifier.value = temaOscuro ? ThemeMode.dark : ThemeMode.light;

  }

  @override

  Widget build(BuildContext context) {

    return ValueListenableBuilder<ThemeMode>(

      valueListenable: themeNotifier,

      builder: (context, themeMode, child) {

        return MaterialApp(

          debugShowCheckedModeBanner: false,

          title: 'DriveWise',

          // ==================================================================

          // TEMA CLARO

          // ==================================================================

          theme: ThemeData(

            useMaterial3: true,

            colorScheme:

                ColorScheme.fromSeed(

                  seedColor: const Color(0xFF16A34A),

                  brightness: Brightness.light,

                ).copyWith(

                  primary: const Color(0xFF16A34A),

                  onPrimary: Colors.white,

                  secondary: const Color(0xFF15803D),

                  surface: const Color(0xFFF7F9F7),

                  onSurface: const Color(0xFF172017),

                  outline: const Color(0xFFD7DED7),

                ),

            scaffoldBackgroundColor: const Color(0xFFF7F9F7),

            cardTheme: const CardThemeData(

              color: Colors.white,

              elevation: 0,

              margin: EdgeInsets.zero,

            ),

            appBarTheme: const AppBarTheme(

              backgroundColor: Colors.white,

              foregroundColor: Color(0xFF172017),

              elevation: 0,

              surfaceTintColor: Colors.transparent,

            ),

            dividerTheme: const DividerThemeData(

              color: Color(0xFFE1E7E1),

              thickness: 1,

              space: 1,

            ),

            switchTheme: SwitchThemeData(

              thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {

                if (states.contains(WidgetState.selected)) {

                  return Colors.white;

                }

                return const Color(0xFF6B7280);

              }),

              trackColor: WidgetStateProperty.resolveWith<Color?>((states) {

                if (states.contains(WidgetState.selected)) {

                  return const Color(0xFF16A34A);

                }

                return const Color(0xFFE5E7EB);

              }),

            ),

          ),

          // ==================================================================

          // TEMA OSCURO

          // ==================================================================

          darkTheme: ThemeData(

            useMaterial3: true,

            colorScheme:

                ColorScheme.fromSeed(

                  seedColor: const Color(0xFF16A34A),

                  brightness: Brightness.dark,

                ).copyWith(

                  primary: const Color(0xFF16A34A),

                  onPrimary: Colors.white,

                  secondary: const Color(0xFF22C55E),

                  surface: const Color(0xFF0F172A),

                  onSurface: const Color(0xFFF8FAFC),

                  outline: const Color(0xFF334155),

                ),

            scaffoldBackgroundColor: const Color(0xFF0F172A),

            cardTheme: const CardThemeData(

              color: Color(0xFF172033),

              elevation: 0,

              margin: EdgeInsets.zero,

            ),

            appBarTheme: const AppBarTheme(

              backgroundColor: Color(0xFF0F172A),

              foregroundColor: Color(0xFFF8FAFC),

              elevation: 0,

              surfaceTintColor: Colors.transparent,

            ),

            dividerTheme: const DividerThemeData(

              color: Color(0xFF293548),

              thickness: 1,

              space: 1,

            ),

            switchTheme: SwitchThemeData(

              thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {

                if (states.contains(WidgetState.selected)) {

                  return Colors.white;

                }

                return const Color(0xFF94A3B8);

              }),

              trackColor: WidgetStateProperty.resolveWith<Color?>((states) {

                if (states.contains(WidgetState.selected)) {

                  return const Color(0xFF16A34A);

                }

                return const Color(0xFF334155);

              }),

            ),

          ),

          // Tema actualmente seleccionado.

          themeMode: themeMode,

          // Pantalla inicial.

          home: LoginPage(

            temaOscuro: themeMode == ThemeMode.dark,

            onCambiarTema: _cambiarTema,

          ),

        );

      },

    );

  }

}



// DASHBOARD



class DashboardPage extends StatefulWidget {
  final bool temaOscuro;
  final ValueChanged<bool> onCambiarTema;
  final String nombreUsuario;

  const DashboardPage({
    super.key,
    required this.temaOscuro,
    required this.onCambiarTema,
    required this.nombreUsuario,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _vehiculosStream;

  @override
  void initState() {
    super.initState();

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      _vehiculosStream = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('vehiculos')
          .snapshots();
    } else {
      _vehiculosStream = const Stream.empty();
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          temaOscuro: widget.temaOscuro,
          onCambiarTema: widget.onCambiarTema,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _registrarVehiculo() async {
  final resultado = await Navigator.push<Vehiculo>(
    context,
    MaterialPageRoute(
      builder: (context) => const RegistroVehiculoPage(),
    ),
  );

  // Si el usuario cancela el formulario, no hacemos nada.
  if (!mounted || resultado == null) {
    return;
  }

  // Si el vehículo se guardó correctamente,
  // abrir la pantalla Mi vehículo.
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MiVehiculoPage(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'DriveWise',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: widget.temaOscuro
                    ? const Color(0xFF172033)
                    : const Color(0xFFF0F3F0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.temaOscuro
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 20,
                    color: widget.temaOscuro
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 2),
                  Switch(
                    value: widget.temaOscuro,
                    onChanged: widget.onCambiarTema,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _vehiculosStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _mensajeEstado(
                context,
                icono: Icons.error_outline,
                titulo: 'No pudimos cargar tus vehículos',
                descripcion:
                    'Ocurrió un problema al consultar la información. Inténtalo nuevamente.',
                accion: TextButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final vehiculos = snapshot.data?.docs ?? [];

            if (vehiculos.isEmpty) {
              return _sinVehiculos(context, theme, colors);
            }

            return _dashboardConVehiculos(
              context,
              theme,
              colors,
              vehiculos,
            );
          },
        ),
      ),
    );
  }

  Widget _sinVehiculos(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          'Hola, ${widget.nombreUsuario}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Te damos la bienvenida a DriveWise. Para comenzar, registra tu primer vehículo.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.directions_car_filled_outlined,
                  size: 46,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Aún no tienes vehículos registrados',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Registra tu automóvil o motocicleta para empezar a llevar el control de su información.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _registrarVehiculo,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar mi primer vehículo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dashboardConVehiculos(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> vehiculos,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Text(
          'Hola, ${widget.nombreUsuario}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Estos son los vehículos que tienes registrados en DriveWise.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        _buildSectionHeader(
          context,
          title: 'Mis vehículos',
          subtitle: '${vehiculos.length} ${vehiculos.length == 1 ? 'vehículo registrado' : 'vehículos registrados'}',
        ),
        const SizedBox(height: 12),
        ...vehiculos.map((documento) {
          final datos = documento.data();
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildVehicleCard(
              context,
              theme,
              colors,
              datos,
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _registrarVehiculo,
          icon: const Icon(Icons.add),
          label: const Text('Agregar otro vehículo'),
        ),
      ],
    );
  }

  Widget _mensajeEstado(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    Widget? accion,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 52, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            if (accion != null) ...[
              const SizedBox(height: 12),
              accion,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    Map<String, dynamic> datos,
  ) {
    final tipo = datos['tipo']?.toString() ?? 'Vehículo';
    final marca = datos['marca']?.toString() ?? '';
    final modelo = datos['modelo']?.toString() ?? '';
    final placa = datos['placa']?.toString() ?? 'Sin placa';
    final kilometraje = datos['kilometraje']?.toString() ?? '0';
    final anio = datos['anio']?.toString() ?? 'Sin año';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MiVehiculoPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      tipo == 'Motocicleta'
                          ? Icons.two_wheeler
                          : Icons.directions_car_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$marca $modelo'.trim(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tipo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      placa,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _VehicleMiniData(
                        icon: Icons.speed_rounded,
                        label: 'Kilometraje',
                        value: '$kilometraje km',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                    Expanded(
                      child: _VehicleMiniData(
                        icon: Icons.calendar_today_rounded,
                        label: 'Año',
                        value: anio,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleMiniData extends StatelessWidget {

  final IconData icon;

  final String label;

  final String value;

  const _VehicleMiniData({

    required this.icon,

    required this.label,

    required this.value,

  });

  @override

  Widget build(BuildContext context) {

    return Row(

      children: [

        Icon(icon, color: Colors.white.withValues(alpha: 0.90), size: 20),

        const SizedBox(width: 9),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                label,

                style: TextStyle(

                  color: Colors.white.withValues(alpha: 0.70),

                  fontSize: 11,

                ),

              ),

              const SizedBox(height: 2),

              Text(

                value,

                style: const TextStyle(

                  color: Colors.white,

                  fontWeight: FontWeight.w700,

                  fontSize: 13,

                ),

              ),

            ],

          ),

        ),

      ],

    );

  }

}

// ============================================================================

// VEHICLE INFO ROW

// ============================================================================

class VehicleInfoRow extends StatelessWidget {

  final IconData icon;

  final String label;

  final String value;

  const VehicleInfoRow({

    super.key,

    required this.icon,

    required this.label,

    required this.value,

  });

  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    return Row(

      children: [

        Container(

          width: 34,

          height: 34,

          decoration: BoxDecoration(

            color: colors.primary.withValues(alpha: 0.10),

            borderRadius: BorderRadius.circular(10),

          ),

          child: Icon(icon, color: colors.primary, size: 19),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: Text(

            label,

            style: theme.textTheme.bodyMedium?.copyWith(

              color: colors.onSurfaceVariant,

            ),

          ),

        ),

        const SizedBox(width: 12),

        Flexible(

          child: Text(

            value,

            textAlign: TextAlign.end,

            style: theme.textTheme.bodyMedium?.copyWith(

              fontWeight: FontWeight.w700,

            ),

          ),

        ),

      ],

    );

  }

}
