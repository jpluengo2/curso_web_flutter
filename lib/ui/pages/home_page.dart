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
  late MultiSplitViewController _splitController;

  final ScrollController _listScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();

  // NUEVO: Estado para controlar qué pestaña se ve en la versión móvil (0: Teoría, 1: Lab)
  int _mobileTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador del SplitView (Solo se usará en Desktop)
    _splitController = MultiSplitViewController(
      areas: [
        Area(
          flex: 1,
          min: 0.15,
          builder: (context, area) => PanelCard(
            title: 'Índice de Lecciones',
            icon: Icons.list_alt_rounded,
            borderColor: Theme.of(context).colorScheme.primary,
            child: _buildSidebarContent(isMobile: false),
          ),
        ),
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) => PanelCard(
            title: 'Conceptos Teóricos',
            icon: Icons.article_outlined,
            borderColor: Theme.of(context).colorScheme.tertiary,
            child: _buildMarkdownContent(),
          ),
        ),
        Area(
          flex: 1,
          min: 0.20,
          builder: (context, area) => PanelCard(
            title: 'Laboratorio en Vivo',
            icon: Icons.science_outlined,
            borderColor: Theme.of(context).colorScheme.secondary,
            child: _buildLaboratoryContent(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotebookProvider>();

    if (provider.isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

    if (provider.lessons.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No se encontraron lecciones en assets/markdown/")),
      );
    }

    // NUEVO: Usamos LayoutBuilder para decidir qué interfaz mostrar según el ancho
    return LayoutBuilder(
      builder: (context, constraints) {
        // Consideramos "Móvil/Tablet pequeña" si el ancho es menor a 900px
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          appBar: AppBar(
            title: RichText(
              overflow: TextOverflow.ellipsis,
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
          
          // NUEVO: Drawer (Menú lateral) solo visible en modo móvil
          drawer: isMobile
              ? Drawer(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PanelCard(
                        title: 'Índice',
                        icon: Icons.list_alt_rounded,
                        borderColor: Theme.of(context).colorScheme.primary,
                        // Le pasamos true para que cierre el drawer al tocar
                        child: _buildSidebarContent(isMobile: true), 
                      ),
                    ),
                  ),
                )
              : null, // En PC no hay Drawer

          // NUEVO: BottomNavigationBar solo visible en modo móvil
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: _mobileTabIndex,
                  onTap: (index) => setState(() => _mobileTabIndex = index),
                  selectedItemColor: Colors.blue.shade900,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.article_outlined),
                      label: 'Teoría',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.science_outlined),
                      label: 'Laboratorio',
                    ),
                  ],
                )
              : null,

          // CUERPO PRINCIPAL: Depende de si es móvil o PC
          body: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
            child: isMobile 
                ? _buildMobileBody(context) 
                : _buildDesktopBody(context),
          ),
        );
      },
    );
  }

  // ==========================================
  // LAYOUTS (Móvil vs Escritorio)
  // ==========================================

  Widget _buildDesktopBody(BuildContext context) {
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 5,
        dividerPainter: DividerPainters.grooved1(
          color: Colors.grey.shade300,
          highlightedColor: Colors.blue,
        ),
      ),
      child: MultiSplitView(
        controller: _splitController,
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    // En móvil, usamos un IndexedStack para mantener el estado de ambas 
    // pestañas (Teoría y Lab) vivas mientras cambiamos entre ellas.
    return IndexedStack(
      index: _mobileTabIndex,
      children: [
        PanelCard(
          title: 'Conceptos Teóricos',
          icon: Icons.article_outlined,
          borderColor: Theme.of(context).colorScheme.tertiary,
          child: _buildMarkdownContent(),
        ),
        PanelCard(
          title: 'Laboratorio en Vivo',
          icon: Icons.science_outlined,
          borderColor: Theme.of(context).colorScheme.secondary,
          child: _buildLaboratoryContent(),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGETS INTERNOS DE CONTENIDO
  // ==========================================

  /// Se le añade un parámetro [isMobile] para saber si debe cerrar el Drawer.
  Widget _buildSidebarContent({required bool isMobile}) {
    final provider = context.watch<NotebookProvider>();
    final lessons = provider.lessons;
    final selectedLesson = provider.selectedLesson;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scrollbar(
      controller: _listScrollController,
      thumbVisibility: true,
      child: ListView.separated(
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
              backgroundColor: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
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
              if (_contentScrollController.hasClients) {
                _contentScrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
              context.read<NotebookProvider>().selectLesson(lesson);
              
              // NUEVO: Si estamos en móvil, cerramos el drawer automáticamente al elegir lección
              if (isMobile) {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMarkdownContent() {
    final provider = context.watch<NotebookProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey(provider.selectedLesson?.markdownPath ?? 'initial'),
        child: provider.isContentLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Scrollbar(
                controller: _contentScrollController,
                thumbVisibility: true,
                child: Markdown(
                  controller: _contentScrollController,
                  data: provider.markdownContent,
                  selectable: true,
                  padding: const EdgeInsets.all(24),
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: const TextStyle(height: 1.5, fontSize: 15),
                    code: TextStyle(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade200,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.blue.shade300 
                          : const Color(0xFF3F51B5),
                      fontFamily: 'monospace',
                      fontSize: 14 * 0.9,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.black54 
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey.shade700 
                            : Colors.grey.shade400
                      ),
                    ),
                    codeblockPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLaboratoryContent() {
    final provider = context.watch<NotebookProvider>();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: ScaffoldMessenger(
        key: ValueKey(provider.selectedLesson?.id ?? 'initial'),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: provider.selectedLabWidget,
        ),
      ),
    );
  }
}