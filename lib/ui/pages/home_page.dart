import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import '../../providers/notebook_provider.dart';
import '../widgets/panel_card.dart';

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
          builder: (context, area) {
            final colorScheme = Theme.of(context).colorScheme;
            return PanelCard(
              title: 'Índice de Lecciones',
              icon: Icons.list_alt_rounded,
              borderColor: colorScheme.primary,
              child: _buildSidebarContent(),
            );
          },
        ),
        // AREA 2: TEORÍA
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) {
            final colorScheme = Theme.of(context).colorScheme;
            return PanelCard(
              title: 'Conceptos Teóricos',
              icon: Icons.article_outlined,
              borderColor: colorScheme.tertiary,
              child: _buildMarkdownContent(),
            );
          },
        ),
        // AREA 3: LABORATORIO
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) {
            final colorScheme = Theme.of(context).colorScheme;
            return PanelCard(
              title: 'Laboratorio en Vivo',
              icon: Icons.science_outlined,
              borderColor: colorScheme.secondary,
              child: _buildLaboratoryContent(),
            );
          },
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
      // 4. Damos un color diferente al margen alrededor de los paneles.
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
      body: Padding(
        // 3. Necesitamos un margen entre el borde inferior de los paneles y el límite de la pantalla.
        padding: const EdgeInsets.all(8.0),
        child: MultiSplitViewTheme(
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
      ),
    );
  }

  // ==========================================
  // WIDGETS DE LOS PANELES
  // ==========================================

  /// Construye el contenido del panel del índice de lecciones (la lista).
  Widget _buildSidebarContent() {
    // Usamos 'read' para obtener el provider para acciones (onTap)
    // y 'watch' para obtener los datos que se reconstruyen (lista y selección).
    final provider = context.watch<NotebookProvider>();
    final lessons = provider.lessons;
    final selectedLesson = provider.selectedLesson;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scrollbar(
      controller: _listScrollController,
      thumbVisibility: true,
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
                  hoverColor: colorScheme.primary.withOpacity(0.05),
                  selected: isSelected,
                  selectedTileColor: colorScheme.primary.withOpacity(0.1),
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                    child: Text(
                      lesson.id,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
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
    );
  }

  /// Construye el contenido del panel de conceptos teóricos (el visor de Markdown).
  Widget _buildMarkdownContent() {
    final provider = context.watch<NotebookProvider>();

    return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Container(
              // La key es crucial para que AnimatedSwitcher detecte el cambio
              key: ValueKey(provider.selectedLesson?.markdownPath ?? 'initial'),
              child: provider.isContentLoading ? const Center(child: CircularProgressIndicator()) : Scaffold(
                      // El fondo debe ser transparente para que se vea el del PanelCard.
                      backgroundColor: Colors.transparent,
                      body: Scrollbar(
                        controller: _contentScrollController,
                        thumbVisibility: true,
                        child: Markdown(
                        // Asignamos el controlador específico para el contenido.
                        controller: _contentScrollController,
                        data: provider.markdownContent,
                        selectable: true,
                        padding: const EdgeInsets.all(24),
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: const TextStyle(height: 1.5, fontSize: 15),
                          // Requerimiento: Tono gris innegociable para el código.
                          // 6. Los recuadros de código en el panel de la teoría deben tener un gris más pronunciado y el código tener un color diferente.
                          code: TextStyle(
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF3F51B5), // Tono índigo para diferenciarlo.
                            fontFamily: 'monospace',
                            fontSize: 14 * 0.9,
                          ),
                          codeblockDecoration: BoxDecoration(
                            // Gris mucho más oscuro para el fondo del bloque.
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          codeblockPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    ),
            ),
    );
  }

  /// Construye el contenido del panel del laboratorio en vivo.
  Widget _buildLaboratoryContent() {
    final provider = context.watch<NotebookProvider>();
    return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
      child: ScaffoldMessenger(
                // La key es crucial para que AnimatedSwitcher detecte el cambio
                key: ValueKey(provider.selectedLesson?.id ?? 'initial'),
        child: Scaffold(
          // El fondo debe ser transparente para que se vea el del PanelCard.
          backgroundColor: Colors.transparent,
          // Usamos el getter del provider para obtener el widget del laboratorio.
          body: provider.selectedLabWidget,
        ),
      ),
    );
  }
}