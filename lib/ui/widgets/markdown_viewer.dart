import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownViewer extends StatelessWidget {
  final String assetPath;

  const MarkdownViewer({super.key, required this.assetPath});

  // Función asíncrona que lee el archivo .md desde los assets
  Future<String> _loadMarkdown() async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      return "### ❌ Error\nNo se pudo cargar el archivo: `$assetPath`\n\nDetalle: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadMarkdown(),
      builder: (context, snapshot) {
        // 1. Mientras carga, mostramos un indicador
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        
        // 2. Si hay datos, renderizamos el Markdown
        return Markdown(
          data: snapshot.data ?? '',
          selectable: true, // ¡Vital! Permite seleccionar y copiar el texto en la web
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          
          // Aquí definimos el "Look & Feel" de nuestros apuntes
          styleSheet: MarkdownStyleSheet(
            h1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            p: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF333333)),
            listBullet: const TextStyle(color: Colors.blue, fontSize: 16),
            
            // --- NUEVO DISEÑO DE CÓDIGO (Gris claro, sin borde) ---
            code: TextStyle(
              backgroundColor: Colors.transparent, // Fondo transparente para que use el del bloque
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.indigo.shade800, // Un azul oscuro/índigo elegante para el texto
            ),
            codeblockDecoration: BoxDecoration(
              color: const Color(0xFFF0F0F0), // Gris muy claro
              borderRadius: BorderRadius.circular(8), // Bordes suaves
              // Eliminado el border para no "remarcarlo"
            ),
            codeblockPadding: const EdgeInsets.all(20),
          ),
        );
      },
    );
  }
}