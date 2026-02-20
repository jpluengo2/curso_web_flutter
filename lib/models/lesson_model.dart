import 'package:flutter/material.dart'; // Necesario para el tipo Widget
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'lesson_registry.dart'; // Importamos el registro para conectar ID con Widget

class Lesson {
  final String id;
  final String title;
  final String markdownPath;
  final Widget liveWidget; 

  Lesson({
    required this.id,
    required this.title,
    required this.markdownPath,
    required this.liveWidget, 
  });

  static Future<List<Lesson>> loadAllLessons() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    // --- SOLUCIÓN ULTRA-FLEXIBLE ---
    // En lugar de usar .startsWith() que es muy estricto, usamos .contains() 
    // y lo pasamos todo a minúsculas (.toLowerCase()). Así, no importa cómo 
    // Android empaquete la ruta internamente, lo encontrará.
    final markdownPaths = allAssets
        .where((String key) => 
            key.toLowerCase().contains('markdown') && 
            key.toLowerCase().endsWith('.md'))
        .toList();

    if (markdownPaths.isEmpty) {
      // CHIVATO: Si sigue fallando, esto imprimirá en tu consola qué archivos
      // ha metido Android realmente dentro de la app para poder investigar.
      debugPrint("⚠️ ALERTA ASSETS: No se encontraron MDs. Total assets empaquetados: ${allAssets.length}");
      debugPrint("⚠️ MUESTRA ASSETS: ${allAssets.take(15).toList()}");
      
      throw Exception(
          'No se encontraron archivos .md en la carpeta "assets/markdown/".\n\n'
          'Por favor, asegúrate de que:\n1. Ejecutaste "flutter clean" en la terminal.\n2. Ejecutaste "flutter pub get".');
    }

    markdownPaths.sort();

    final List<Lesson> loadedLessons = [];
    for (String path in markdownPaths) {
      final fileName = path.split('/').last;
      
      // Ignoramos mayúsculas/minúsculas también en la extensión (.MD o .md)
      final nameWithoutExt = fileName.replaceAll(RegExp(r'\.md$', caseSensitive: false), '');
      final parts = nameWithoutExt.split('_');

      if (parts.length >= 2) {
        final id = parts[0];
        final rawTitle = parts.sublist(1).join(' ');
        final title = rawTitle[0].toUpperCase() + rawTitle.substring(1);

        final Widget widget = lessonRegistry[id] ?? defaultPlaceholder;

        loadedLessons.add(Lesson(
            id: id, title: title, markdownPath: path, liveWidget: widget));
      }
    }
    return loadedLessons;
  }
}