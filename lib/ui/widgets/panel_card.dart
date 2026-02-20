import 'package:flutter/material.dart';

/// Un widget que dibuja un marco estilizado alrededor de un panel de contenido.
/// Incluye controles de escala (Zoom lógico/Reflow) independientes.
class PanelCard extends StatefulWidget {
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
  State<PanelCard> createState() => _PanelCardState();
}

class _PanelCardState extends State<PanelCard> {
  // Estado local para la escala del texto e iconos
  double _scale = 1.0;

  void _zoomIn() {
    setState(() {
      // Usamos toStringAsFixed para evitar errores de precisión decimal (ej. 1.0999999)
      if (_scale < 2.5) {
        _scale = double.parse((_scale + 0.1).toStringAsFixed(1));
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_scale > 0.5) {
        _scale = double.parse((_scale - 0.1).toStringAsFixed(1));
      }
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final frameColor = Color.alphaBlend(widget.borderColor.withOpacity(0.45), theme.colorScheme.surface);
    final contentBgColor = Color.alphaBlend(widget.borderColor.withOpacity(0.04), theme.colorScheme.surface);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // --- PANEL DE CONTENIDO ---
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container( 
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: frameColor, 
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.only(top: 28.0, left: 4, right: 4, bottom: 4),
              child: Container( 
                decoration: BoxDecoration(
                  color: contentBgColor, 
                  borderRadius: BorderRadius.circular(8), 
                ),
                clipBehavior: Clip.antiAlias,
                
                // === MAGIA DEL REFLOW (ZOOM LÓGICO) AQUÍ ===
                // En lugar de una lupa visual (Transform), le decimos al sub-árbol 
                // que el texto y los iconos deben ser más grandes/pequeños. 
                // Esto obliga a Flutter a recalcular los saltos de línea sin desbordar el panel.
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(_scale),
                  ),
                  child: Theme(
                    data: theme.copyWith(
                      iconTheme: theme.iconTheme.copyWith(
                        size: (theme.iconTheme.size ?? 24.0) * _scale,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
                
              ),
            ),
          ),
        ),
        // --- ETIQUETA DEL TÍTULO Y CONTROLES ---
        Positioned(
          top: -2,   // Lo subimos 2 píxeles para que sobresalga un poco más.
          left: 0,   // Lo extendemos hasta el borde izquierdo del panel.
          right: 0,  // Lo extendemos hasta el borde derecho del panel.
          height: 40,
          child: Container( 
            decoration: BoxDecoration(
              color: widget.borderColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  // CORRECCIÓN: Usamos el color de sombra del tema.
                  color: theme.shadowColor.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(widget.icon, color: theme.colorScheme.onPrimary, size: 18),
                const SizedBox(width: 10),
                
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(), 
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // === BOTONES DE CONTROL ===
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  color: theme.colorScheme.onPrimary,
                  disabledColor: theme.colorScheme.onPrimary.withOpacity(0.3),
                  onPressed: _scale > 0.5 ? _zoomOut : null,
                  tooltip: 'Reducir tamaño',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                
                GestureDetector(
                  onTap: _resetZoom,
                  child: Tooltip(
                    message: 'Restablecer (100%)',
                    child: Container(
                      width: 45, 
                      alignment: Alignment.center,
                      child: Text(
                        '${(_scale * 100).toInt()}%',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: theme.colorScheme.onPrimary,
                  disabledColor: theme.colorScheme.onPrimary.withOpacity(0.3),
                  onPressed: _scale < 2.5 ? _zoomIn : null,
                  tooltip: 'Aumentar tamaño',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}