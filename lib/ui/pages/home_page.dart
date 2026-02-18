import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import '../../providers/notebook_provider.dart';

class NotebookHomePage extends StatefulWidget {
  const NotebookHomePage({super.key});

  @override
  State<NotebookHomePage> createState() => _NotebookHomePageState();
}

class _NotebookHomePageState extends State<NotebookHomePage> {
  // El estado de la UI (controlador del SplitView) se mantiene aquí.
  // La lógica de la aplicación (lecciones, selección) se mueve al Provider.
  late MultiSplitViewController _splitController;

  // SOLUCIÓN DEFINITIVA: Controladores de scroll explícitos para cada área.
  // Esto garantiza que no se compartan controladores y elimina la excepción.
  final ScrollController _listScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // ============================================================
    // CORRECCIÓN: INICIALIZACIÓN DEL CONTROLADOR
    // ============================================================
    // El controlador se inicializa una vez. Los builders de las áreas
    // ahora obtendrán los datos directamente del Provider.
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
          builder: (context, area) => _buildMarkdownViewer(),
        ),
        // AREA 3: LABORATORIO
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) => _buildLaboratoryPanel(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Es crucial liberar los controladores para evitar fugas de memoria.
    _listScrollController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observamos el provider para reaccionar a los cambios de estado.
    final provider = context.watch<NotebookProvider>();

    // 1. Carga inicial
    if (provider.isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Estado de Error (NUEVO)
    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de Carga')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // 3. Estado de "No encontrado" (si la carga fue exitosa pero no hay lecciones)
    if (provider.lessons.isEmpty) {
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
                text: provider.selectedLesson?.title ?? 'Cargando...',
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
          // El controlador ya está inicializado y listo para usar.
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
    // Usamos 'read' para obtener el provider para acciones (onTap)
    // y 'watch' para obtener los datos que se reconstruyen (lista y selección).
    final provider = context.watch<NotebookProvider>();
    final lessons = provider.lessons;
    final selectedLesson = provider.selectedLesson;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelHeader(
              icon: Icons.list_alt_rounded, title: "ÍNDICE DE MATERIAS"),
          Expanded(
            child: ListView.separated(
              // Asignamos el controlador específico para la lista.
              controller: _listScrollController,
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isSelected = selectedLesson == lesson;
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
                  onTap: () {
                    // MEJORA: Al hacer clic, primero hacemos scroll hacia arriba en el panel de contenido.
                    if (_contentScrollController.hasClients) {
                      _contentScrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                    context.read<NotebookProvider>().selectLesson(lesson);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownViewer() {
    final provider = context.watch<NotebookProvider>();

    return Column(
      children: [
        _buildPanelHeader(
          icon: Icons.article_outlined,
          title: "CONCEPTOS TEÓRICOS BÁSICOS",
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Container(
              // La key es crucial para que AnimatedSwitcher detecte el cambio
              key: ValueKey(provider.selectedLesson?.markdownPath ?? 'initial'),
              child: provider.isContentLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Scaffold(
                      backgroundColor: Colors.white,
                      body: Markdown(
                        // Asignamos el controlador específico para el contenido.
                        controller: _contentScrollController,
                        data: provider.markdownContent,
                        selectable: true,
                        padding: const EdgeInsets.all(24),
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                          p: const TextStyle(height: 1.5, fontSize: 15),
                          code: TextStyle(
                            backgroundColor:
                                Colors.blue.shade50.withOpacity(0.5),
                            color: Colors.indigo.shade800,
                            fontFamily: 'monospace',
                            fontSize: 14 * 0.9,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          codeblockPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaboratoryPanel() {
    final provider = context.watch<NotebookProvider>();
    return Container(
      color: Colors.blue.shade200,
      child: Column(
        children: [
          _buildPanelHeader(
            icon: Icons.science_outlined,
            title: "LABORATORIO EN VIVO",
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Padding(
                // La key es crucial para que AnimatedSwitcher detecte el cambio
                key: ValueKey(provider.selectedLesson?.id ?? 'initial'),
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
                        // Usamos el getter del provider para obtener el widget del laboratorio.
                        body: provider.selectedLabWidget,
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