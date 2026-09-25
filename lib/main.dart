import 'package:flutter/material.dart';

import 'gastos.dart';
import 'recordatorios.dart';
import 'login.dart';
import 'mi_vehiculo.dart';

import 'widgets/reminder_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/vehicle_status_row.dart';

void main() {
  runApp(const MainApp());
}

// ============================================================================
// ESTADO GLOBAL DEL TEMA
// ============================================================================

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

// ============================================================================
// DASHBOARD
// ============================================================================

class DashboardPage extends StatelessWidget {
  final bool temaOscuro;
  final ValueChanged<bool> onCambiarTema;

  const DashboardPage({
    super.key,
    required this.temaOscuro,
    required this.onCambiarTema,
  });

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
                color: temaOscuro
                    ? const Color(0xFF172033)
                    : const Color(0xFFF0F3F0),
                borderRadius: BorderRadius.circular(22),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    temaOscuro
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 20,
                    color: temaOscuro
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF475569),
                  ),

                  const SizedBox(width: 2),

                  Switch(value: temaOscuro, onChanged: onCambiarTema),
                ],
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    temaOscuro: temaOscuro,
                    onCambiarTema: onCambiarTema,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            // =================================================================
            // ENCABEZADO
            // =================================================================

            Text(
              'Hola, Santiago',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Gestiona toda la información de tu vehículo desde un solo lugar.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 22),

            // =================================================================
            // VEHÍCULO
            // =================================================================
            _buildVehicleCard(context, theme, colors),

            const SizedBox(height: 25),

            // =================================================================
            // ESTADO DEL VEHÍCULO
            // =================================================================
            _buildSectionHeader(
              context,
              title: 'Estado del vehículo',
              subtitle: 'Resumen del estado actual',
            ),

            const SizedBox(height: 12),

            _buildVehicleStatusCard(context, theme, colors),

            const SizedBox(height: 25),

            // =================================================================
            // RESUMEN
            // =================================================================
            _buildSectionHeader(
              context,
              title: 'Resumen',
              subtitle: 'Lo que requiere tu atención',
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.build_circle_outlined,
                    title: 'Mantenimiento',
                    value: '2 pendientes',
                    accentColor: colors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GastosPage()),
                      );
                    },
                    child: const SummaryCard(
                      icon: Icons.attach_money_outlined,
                      title: 'Gastos',
                      value: '4 registrados',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordatoriosPage(),
                  ),
                );
              },
              child: const SummaryCard(
                icon: Icons.notifications_outlined,
                title: 'Recordatorios',
                value: '3 activos',
              ),
            ),

            const SizedBox(height: 25),

            // =================================================================
            // PRÓXIMOS RECORDATORIOS
            // =================================================================
            _buildSectionHeader(
              context,
              title: 'Próximos recordatorios',
              subtitle: 'No olvides estas tareas',
            ),

            const SizedBox(height: 12),

            const ReminderCard(
              icon: Icons.oil_barrel_outlined,
              title: 'Cambio de aceite',
              description: 'Programado para los próximos 1.200 km',
              tag: '1.200 km',
            ),

            const SizedBox(height: 10),

            const ReminderCard(
              icon: Icons.build_circle_outlined,
              title: 'Revisión técnico-mecánica',
              description: 'Pendiente para el próximo mes',
              tag: 'Próximo mes',
            ),

            const SizedBox(height: 10),

            const ReminderCard(
              icon: Icons.description_outlined,
              title: 'Documentos del vehículo',
              description: 'Revisar vencimiento del seguro',
              tag: 'Revisar',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ENCABEZADO DE SECCIÓN
  // ==========================================================================

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

  // ==========================================================================
  // TARJETA DEL VEHÍCULO
  // ==========================================================================

  Widget _buildVehicleCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MiVehiculoPage()),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(17),
                    ),

                    child: const Icon(
                      Icons.directions_car_rounded,
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
                          'Mi vehículo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Mazda 3 Touring',
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
                    child: const Text(
                      'ABC 123',
                      style: TextStyle(
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
                        value: '42.580 km',
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
                        value: '2024',
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

  // ==========================================================================
  // ESTADO DEL VEHÍCULO
  // ==========================================================================

  Widget _buildVehicleStatusCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.65)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            VehicleStatusRow(
              icon: Icons.check_circle_outline_rounded,
              title: 'Motor',
              status: 'En buen estado',
              statusColor: colors.primary,
            ),

            const Divider(height: 20),

            VehicleStatusRow(
              icon: Icons.battery_charging_full_rounded,
              title: 'Batería',
              status: 'Nivel óptimo',
              statusColor: colors.primary,
            ),

            const Divider(height: 20),

            VehicleStatusRow(
              icon: Icons.tire_repair_rounded,
              title: 'Neumáticos',
              status: 'Revisión recomendada',
              statusColor: const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MINI DATO DEL VEHÍCULO
// ============================================================================

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
