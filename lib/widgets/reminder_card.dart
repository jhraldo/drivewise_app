import 'package:flutter/material.dart';

// ============================================================
// REMINDER CARD
// ============================================================
//
// Widget reutilizable para mostrar un recordatorio relacionado
// con el vehículo.
//
// Incluye un ícono, título, descripción y una etiqueta que
// indica información adicional del recordatorio.
//
// Utiliza el tema actual de DriveWise para funcionar tanto
// en modo claro como en modo oscuro.
// ============================================================

class ReminderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String tag;

  const ReminderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícono que representa el tipo de recordatorio.
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: colors.primary,
                size: 23,
              ),
            ),

            const SizedBox(width: 13),

            // Información principal del recordatorio.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Etiqueta con información adicional.
            Container(
              constraints: const BoxConstraints(
                maxWidth: 92,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                tag,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Indica que puede existir más información.
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}