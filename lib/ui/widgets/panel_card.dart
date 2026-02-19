import 'package:flutter/material.dart';

/// Un widget que dibuja un marco estilizado alrededor de un panel de contenido.
class PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color borderColor;
  final IconData icon;

  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    required this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- CAPAS DE COLOR PARA PROFUNDIDAD VISUAL ---
    // Color del "marco interior" (el área de padding).
    // Mezclamos el color del borde con el color de la superficie para un tinte oscuro pero opaco.
    final frameColor = Color.alphaBlend(borderColor.withOpacity(0.45), theme.colorScheme.surface);

    // Color del "fondo de contenido".
    // Mezclamos con una opacidad muy baja para un tinte "perla", casi blanco pero con un toque de color.
    final contentBgColor = Color.alphaBlend(borderColor.withOpacity(0.04), theme.colorScheme.surface);

    // Usamos un Stack para superponer la etiqueta del título sobre el panel de contenido.
    return Stack(
      clipBehavior: Clip.none, // Permite que la etiqueta sobresalga.
      children: [
        // --- PANEL DE CONTENIDO CON DOBLE FONDO ---
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container( // Contenedor del "marco interior"
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: frameColor, // Se aplica el color del marco interior
            ),
            clipBehavior: Clip.antiAlias,
            // Este Padding crea el efecto visual del "marco interior"
            child: Padding(
              padding: const EdgeInsets.only(top: 28.0, left: 4, right: 4, bottom: 4),
              child: Container( // Contenedor del "fondo de contenido"
                decoration: BoxDecoration(
                  color: contentBgColor, // Se aplica el color de fondo final
                  borderRadius: BorderRadius.circular(8), // Bordes más suaves
                ),
                clipBehavior: Clip.antiAlias,
                child: child, // Aquí va el contenido real (ListView, Markdown, etc.)
              ),
            ),
          ),
        ),
        // --- ETIQUETA DEL TÍTULO ---
        // Se posiciona en la parte superior, centrada y abarcando el ancho.
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          height: 40,
          child: Container( // El diseño de la etiqueta se mantiene
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: theme.colorScheme.onPrimary, size: 18),
                const SizedBox(width: 10),
                Text(title.toUpperCase(), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}