import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curso_web_flutter/models/lesson_model.dart';
import 'package:curso_web_flutter/models/lesson_registry.dart';

/// Gestiona el estado de la aplicación del cuaderno.
///
/// Responsabilidades:
/// - Mantener la lista de lecciones una vez cargada.
/// - Mantener la lección actualmente seleccionada.
/// - Cargar y proveer el contenido Markdown de la lección seleccionada.
class NotebookProvider extends ChangeNotifier {
  List<Lesson> _lessons = [];
  Lesson? _selectedLesson;
  String _markdownContent = '### Selecciona una lección para empezar';
  bool _isLoadingContent = false;

  // Getters públicos para acceder al estado desde la UI
  List<Lesson> get lessons => _lessons;
  Lesson? get selectedLesson => _selectedLesson;
  String get markdownContent => _markdownContent;
  bool get isLoadingContent => _isLoadingContent;

  /// Devuelve el widget del laboratorio correspondiente a la lección seleccionada.
  Widget get selectedLabWidget {
    // El widget en vivo ya está convenientemente almacenado en el modelo de la lección.
    return _selectedLesson?.liveWidget ?? defaultPlaceholder;
  }

  /// Este método es llamado por el FutureBuilder una vez que las lecciones se han cargado.
  void setLessons(List<Lesson> loadedLessons) {
    _lessons = loadedLessons;
    // Si no hay ninguna lección seleccionada, seleccionamos la primera por defecto.
    if (_lessons.isNotEmpty && _selectedLesson == null) {
      selectLesson(_lessons.first);
    } else {
      // Si ya había una seleccionada, solo notificamos para que la lista se actualice.
      notifyListeners();
    }
  }

  /// Selecciona una lección y carga su contenido Markdown.
  Future<void> selectLesson(Lesson lesson) async {
    // Evita recargar si ya está seleccionada.
    if (_selectedLesson == lesson) return;

    _selectedLesson = lesson;
    _isLoadingContent = true;
    notifyListeners(); // Notifica para mostrar el indicador de carga.

    try {
      _markdownContent = await rootBundle.loadString(lesson.markdownPath);
    } catch (e) {
      _markdownContent = '### Error al cargar el contenido de la lección:\n\n$e';
    }

    _isLoadingContent = false;
    notifyListeners(); // Notifica para mostrar el contenido cargado.
  }
}
