import 'package:flutter/material.dart';

/// Widget modular que envuelve cualquier vista y le añade un botón flotante
/// para visualizar su código fuente.
class LabCodeViewer extends StatelessWidget {
  final Widget child;
  final String code;

  const LabCodeViewer({
    super.key, 
    required this.child, 
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. El laboratorio interactivo original
        child, 
        
        // 2. El botón flotante en la esquina inferior derecha
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            mini: true,
            tooltip: 'Ver código de este laboratorio',
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => _showCodeDialog(context),
            child: const Icon(Icons.code_rounded),
          ),
        ),
      ],
    );
  }

  void _showCodeDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 800,
          height: 600,
          child: Column(
            children: [
              // CABECERA DE LA VENTANA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade300,
                  border: Border(bottom: BorderSide(color: isDark ? Colors.black54 : Colors.grey.shade400)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.terminal, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Código Fuente del Laboratorio', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              ),
              // CUERPO DEL CÓDIGO
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: SelectableText(
                      code,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? const Color(0xFF9CDCFE) : const Color(0xFF3F51B5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}