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
  // --- ESTADO INTERNO ---
  List<Lesson> _lessons = [];
  Lesson? _selectedLesson;
  String _markdownContent = '### Selecciona una lección para empezar';
  
  // --- ESTADO DE LA CARGA ---
  bool _isInitialLoading = true;
  bool _isContentLoading = false;
  String? _error;

  // --- GETTERS PÚBLICOS ---
  List<Lesson> get lessons => _lessons;
  Lesson? get selectedLesson => _selectedLesson;
  String get markdownContent => _markdownContent;
  bool get isInitialLoading => _isInitialLoading;
  bool get isContentLoading => _isContentLoading;
  String? get error => _error;

  /// Devuelve el widget del laboratorio correspondiente a la lección seleccionada.
  Widget get selectedLabWidget {
    return _selectedLesson?.liveWidget ?? defaultPlaceholder;
  }

  /// Constructor: Inicia la carga inicial de lecciones.
  NotebookProvider() {
    _loadInitialLessons();
  }

  Future<void> _loadInitialLessons() async {
    try {
      _lessons = await Lesson.loadAllLessons();
      if (_lessons.isNotEmpty) {
        // Selecciona la primera lección por defecto al iniciar.
        // No usamos 'await' para no bloquear la primera renderización.
        selectLesson(_lessons.first);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// Selecciona una lección y carga su contenido Markdown.
  Future<void> selectLesson(Lesson lesson) async {
    // Evita recargar si ya está seleccionada (a menos que sea la carga inicial).
    if (_selectedLesson == lesson && !_isInitialLoading) return;

    _selectedLesson = lesson;
    _isContentLoading = true;
    notifyListeners(); // Notifica para mostrar el indicador de carga.

    try {
      _markdownContent = await rootBundle.loadString(lesson.markdownPath);
    } catch (e) {
      _markdownContent = '### Error al cargar el contenido de la lección:\n\n$e';
    }

    _isContentLoading = false;
    notifyListeners(); // Notifica para mostrar el contenido cargado.
  }
}
