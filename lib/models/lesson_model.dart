import 'package:flutter/material.dart'; // Necesario para el tipo Widget
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'lesson_registry.dart'; // Importamos el registro para conectar ID con Widget

class Lesson {
  final String id;
  final String title;
  final String markdownPath;
  final Widget liveWidget; // <--- ¡ESTA ES LA PROPIEDAD QUE FALTABA!

  Lesson({
    required this.id,
    required this.title,
    required this.markdownPath,
    required this.liveWidget, // Requerido en el constructor
  });

  static Future<List<Lesson>> loadAllLessons() async {
    // --- SOLUCIÓN DEFINITIVA Y RECOMENDADA ---
    // Usamos AssetManifest.loadFromAssetBundle, que se encarga de encontrar
    // el archivo de manifiesto correcto ('AssetManifest.json' o 'asset_manifest.json')
    // de forma automática. Esto elimina la necesidad del bloque try-catch manual
    // y es la forma oficial y más robusta de cargar el manifiesto.
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    // El método listAssets() nos da directamente la lista de rutas de los assets.
    final markdownPaths = manifest
        .listAssets()
        .where((String key) => key.startsWith('assets/markdown/') && key.endsWith('.md'))
        .toList();

    // --- MEJORA DE DIAGNÓSTICO ---
    // Si después de buscar en el manifiesto no se encuentra ninguna ruta de markdown,
    // lanzamos un error explícito. Esto será capturado en la UI y mostrará un
    // mensaje mucho más útil que el simple "No se encontraron lecciones".
    if (markdownPaths.isEmpty) {
      throw Exception(
          'No se encontraron archivos .md en la carpeta "assets/markdown/".\n\n'
          'Por favor, asegúrate de que:\n1. Los archivos existen en esa ruta.\n2. La carpeta está declarada correctamente en tu archivo pubspec.yaml (ej: "assets:\\n  - assets/markdown/").');
    }

    markdownPaths.sort();

    final List<Lesson> loadedLessons = [];
    for (String path in markdownPaths) {
      final fileName = path.split('/').last;
      final nameWithoutExt = fileName.replaceAll('.md', '');
      final parts = nameWithoutExt.split('_');

      if (parts.length >= 2) {
        final id = parts[0];
        final rawTitle = parts.sublist(1).join(' ');
        final title = rawTitle[0].toUpperCase() + rawTitle.substring(1);

        // Buscamos el widget en el registro. Si no existe, ponemos el placeholder.
        final Widget widget = lessonRegistry[id] ?? defaultPlaceholder;

        loadedLessons.add(Lesson(
            id: id, title: title, markdownPath: path, liveWidget: widget));
      }
    }
    return loadedLessons;
  }
}