import 'package:flutter/material.dart';

// ============================================================
// SUMMARY CARD
// ============================================================
//
// Widget reutilizable para mostrar información resumida,
// acompañado de un ícono y un valor principal.
//
// Se adapta automáticamente al tema claro u oscuro de
// la aplicación mediante Theme.of(context).
// ============================================================

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? accentColor;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Si no se proporciona un color personalizado, utiliza
    // el color principal definido en el tema de DriveWise.
    final accent = accentColor ?? colors.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono principal y indicador de navegación.
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 22,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Nombre de la información.
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            // Valor principal mostrado en la tarjeta.
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}