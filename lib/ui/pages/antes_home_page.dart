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
    final lessons = await Lesson.loadAllLessons();
    if (mounted) {
      setState(() {
        _lessons = lessons;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Carga
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Validación
    if (_lessons.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No se encontraron lecciones en assets/markdown/")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaderno de Flutter'),
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

  // ==========================================
  // WIDGETS DE LOS PANELES
  // ==========================================

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "ÍNDICE DE TEMAS",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _lessons.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                final isSelected = _selectedIndex == index;
                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                    child: Text(lesson.id, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black87)),
                  ),
                  title: Text(lesson.title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
    return FutureBuilder<String>(
      key: ValueKey(lesson.markdownPath),
      future: rootBundle.loadString(lesson.markdownPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return Scaffold(
          backgroundColor: Colors.white,
          body: Markdown(
            data: snapshot.data!,
            selectable: true,
            padding: const EdgeInsets.all(24),
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              code: TextStyle(backgroundColor: Colors.grey.shade100, color: Colors.indigo, fontFamily: 'monospace'),
              codeblockDecoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLaboratoryPanel(Lesson lesson) {
    return Container(
      color: const Color(0xFFEBEFF1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: [
                const Icon(Icons.science, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text("LABORATORIO EN VIVO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
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
        ],
      ),
    );
  }
}