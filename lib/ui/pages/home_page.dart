import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../../models/lesson_model.dart';

class NotebookHomePage extends StatefulWidget {
  const NotebookHomePage({super.key});

  @override
  State<NotebookHomePage> createState() => _NotebookHomePageState();
}

class _NotebookHomePageState extends State<NotebookHomePage> {
  // Controlador para los paneles
  late MultiSplitViewController _splitController;

  // Estado local
  List<Lesson> _lessons = [];
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error; // Variable para almacenar el mensaje de error

  @override
  void initState() {
    super.initState();

    // ============================================================
    // CORRECCIÓN: INICIALIZACIÓN DEL CONTROLADOR
    // ============================================================
    // El controlador debe inicializarse UNA SOLA VEZ en initState.
    // Ponerlo en `build` lo recrea en cada rebuild, perdiendo el estado
    // de los divisores y causando ineficiencias.
    // Los `builders` de las áreas son closures, por lo que accederán
    // al estado (_lessons, _selectedIndex) más reciente cuando se ejecuten.
    _splitController = MultiSplitViewController(
      areas: [
        // AREA 1: SIDEBAR
        Area(
          flex: 1,
          min: 0.15,
          builder: (context, area) => _buildSidebar(),
        ),
        // AREA 2: TEORÍA
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) {
            if (_lessons.isEmpty) return const SizedBox.shrink();
            return _buildMarkdownViewer(_lessons[_selectedIndex]);
          },
        ),
        // AREA 3: LABORATORIO
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) {
            if (_lessons.isEmpty) return const SizedBox.shrink();
            return _buildLaboratoryPanel(_lessons[_selectedIndex]);
          },
        ),
      ],
    );
    _initLessons();
  }

  Future<void> _initLessons() async {
    try {
      final lessons = await Lesson.loadAllLessons();
      if (mounted) {
        setState(() {
          _lessons = lessons;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Si ocurre un error durante la carga, lo capturamos aquí.
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Carga
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Estado de Error (NUEVO)
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de Carga')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // 3. Estado de "No encontrado" (si la carga fue exitosa pero no hay lecciones)
    if (_lessons.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No se encontraron lecciones en assets/markdown/")),
      );
    }

    // 4. Estado de Éxito: Muestra la UI principal
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          overflow: TextOverflow.ellipsis, // Evita el desbordamiento con títulos largos
          text: TextSpan(
            text: 'Curso Web de Flutter: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            children: <TextSpan>[
              TextSpan(
                text: _lessons[_selectedIndex].title,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 5,
          dividerPainter: DividerPainters.grooved1(
            color: Colors.grey.shade300,
            highlightedColor: Colors.blue,
          ),
        ),
        child: MultiSplitView(
          // El controlador ya está inicializado en initState.
          // Simplemente lo usamos aquí.
          controller: _splitController, 
        ),
      ),
    );
  }

  /// Construye un encabezado de panel estandarizado.
  Widget _buildPanelHeader({required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [Shadow(blurRadius: 2.0, color: Colors.black26)],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGETS DE LOS PANELES
  // ==========================================

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelHeader(
              icon: Icons.list_alt_rounded, title: "ÍNDICE DE MATERIAS"),
          Expanded(
            child: ListView.separated(
              itemCount: _lessons.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                final isSelected = _selectedIndex == index;
                return ListTile(
                  dense: true,
                  hoverColor: Colors.blue.withOpacity(0.05),
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                    child: Text(
                      lesson.id,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black54),
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                    ),
                  ),
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownViewer(Lesson lesson) {
    return Column(
      children: [
        _buildPanelHeader(
          icon: Icons.article_outlined,
          title: "CONCEPTOS TEÓRICOS BÁSICOS",
        ),
        Expanded( // <-- El Expanded ahora envuelve al AnimatedSwitcher
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: FutureBuilder<String>(
              // La key es crucial para que AnimatedSwitcher detecte el cambio
              key: ValueKey(lesson.markdownPath),
              future: rootBundle.loadString(lesson.markdownPath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return const Center(child: Text("No se pudo cargar el contenido."));
                }
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Markdown(
                    data: snapshot.data!,
                    selectable: true,
                    padding: const EdgeInsets.all(24),
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      // Estilo para el texto normal (párrafos), manteniendo la fuente que te gustó.
                      p: const TextStyle(height: 1.5, fontSize: 15),

                      // Estilo para el código inline (`código`)
                      code: TextStyle(
                        backgroundColor: Colors.blue.shade50.withOpacity(0.5),
                        color: Colors.indigo.shade800,
                        fontFamily: 'monospace',
                        fontSize: 14 * 0.9,
                      ),
                      // Estilo para los bloques de código (```código```)
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA), // Un fondo gris azulado muy claro
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      codeblockPadding: const EdgeInsets.all(16),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaboratoryPanel(Lesson lesson) {
    return Container(
      color: Colors.blue.shade200, // Azul perla intenso
      child: Column(
        children: [
          _buildPanelHeader(
            icon: Icons.science_outlined,
            title: "LABORATORIO EN VIVO",
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Padding(
                // La key es crucial para que AnimatedSwitcher detecte el cambio
                key: ValueKey(lesson.id),
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ScaffoldMessenger(
                      child: Scaffold(
                        body: lesson.liveWidget,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}