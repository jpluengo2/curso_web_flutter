import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'lesson_registry.dart'; 

class Lesson {
  final String id;
  final String title;
  final String markdownPath;
  final Widget liveWidget; 
  final String content; 
  // NUEVO: Guardaremos el código del laboratorio aquí
  final String labCode; 

  Lesson({
    required this.id,
    required this.title,
    required this.markdownPath,
    required this.liveWidget, 
    required this.content, 
    required this.labCode, // Requerido al construir
  });

  static Future<List<Lesson>> loadAllLessons() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> allAssets = manifest.listAssets();

      final List<String> markdownPaths = allAssets
          .where((String key) => key.toLowerCase().contains('markdown') && key.toLowerCase().endsWith('.md'))
          .toList();

      // NUEVO: Listamos también todos los archivos .dart de la carpeta lessons
      final List<String> dartPaths = allAssets
          .where((String key) => key.toLowerCase().startsWith('lib/lessons/') && key.toLowerCase().endsWith('.dart'))
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

          final String fileContent = await rootBundle.loadString(path);
          
          // NUEVO: Buscamos el archivo .dart que coincida con el ID y cargamos su código fuente
          String sourceCode = "Código fuente no disponible para este laboratorio.";
          try {
            final dartFilePath = dartPaths.firstWhere((p) => p.split('/').last.startsWith('${id}_'));
            sourceCode = await rootBundle.loadString(dartFilePath);
          } catch (_) {
            // Si el archivo .dart no existe en la carpeta, dejamos el mensaje de error por defecto
          }

          loadedLessons.add(
            Lesson(
              id: id, 
              title: title, 
              markdownPath: path, 
              liveWidget: widget,
              content: fileContent,
              labCode: sourceCode, // Guardamos el código fuente
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