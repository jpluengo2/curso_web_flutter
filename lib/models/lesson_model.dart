import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'lesson_registry.dart'; 

class Lesson {
  final String id;
  final String title;
  final String markdownPath;
  final Widget liveWidget; 
  // NUEVO: Almacenaremos el texto completo de la teoría aquí
  final String content; 

  Lesson({
    required this.id,
    required this.title,
    required this.markdownPath,
    required this.liveWidget, 
    required this.content, // Requerido al construir
  });

  static Future<List<Lesson>> loadAllLessons() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> allAssets = manifest.listAssets();

      final List<String> markdownPaths = allAssets
          .where((String key) => 
              key.toLowerCase().contains('markdown') && 
              key.toLowerCase().endsWith('.md'))
          .toList();

      if (markdownPaths.isEmpty) {
        throw Exception('No se encontraron archivos .md en la carpeta "assets/markdown/".');
      }

      markdownPaths.sort();
      final List<Lesson> loadedLessons = [];
      
      for (String path in markdownPaths) {
        final String fileName = path.split('/').last;
        final String nameWithoutExt = fileName.replaceAll(RegExp(r'\.md$', caseSensitive: false), '');
        final List<String> parts = nameWithoutExt.split('_');

        if (parts.isNotEmpty) {
          final String id = parts[0];
          
          String title = "Lección $id";
          if (parts.length >= 2) {
            final String rawTitle = parts.sublist(1).join(' ');
            title = rawTitle[0].toUpperCase() + rawTitle.substring(1);
          }

          final Widget widget = lessonRegistry[id] ?? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.construction, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text("Laboratorio en construcción...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
          );

          // MAGIA AQUÍ: Cargamos el texto completo de la teoría en memoria
          final String fileContent = await rootBundle.loadString(path);

          loadedLessons.add(
            Lesson(
              id: id, 
              title: title, 
              markdownPath: path, 
              liveWidget: widget,
              content: fileContent, // Guardamos el texto para poder buscarlo luego
            )
          );
        }
      }
      return loadedLessons;
      
    } catch (e) {
      debugPrint("Error crítico cargando las lecciones: $e");
      rethrow; 
    }
  }
}