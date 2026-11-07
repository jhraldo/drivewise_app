import 'package:flutter/material.dart';

// ============================================================
// VEHICLE STATUS ROW
// ============================================================
//
// Widget reutilizable para mostrar el estado de una parte
// específica del vehículo, como el motor, la batería o los
// neumáticos.
//
// El color del estado permite diferenciar visualmente entre
// elementos en buen estado y aquellos que requieren atención.
// ============================================================

class VehicleStatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final Color? statusColor;

  const VehicleStatusRow({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Utiliza el color recibido o, si no existe, el color
    // secundario del tema actual.
    final Color effectiveStatusColor =
        statusColor ?? colors.onSurfaceVariant;

    return Row(
      children: [
        // Ícono que representa el componente del vehículo.
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: effectiveStatusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: effectiveStatusColor,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        // Nombre del componente.
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Estado actual del componente.
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: effectiveStatusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              status,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: effectiveStatusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}