import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

import '../../providers/notebook_provider.dart';
import '../../config/app_theme.dart';
import '../../models/lesson_model.dart';
import '../widgets/panel_card.dart';

// NUEVO: Importamos nuestro buscador aislado
import '../delegates/lesson_search_delegate.dart'; 
import '../widgets/lab_code_viewer.dart';

// =================================================================
// 1. BUILDER PARA DIFERENCIAR PANELES DE INFORMACIÓN Y CÓDIGO
// =================================================================
class CustomPreBuilder extends MarkdownElementBuilder {
  final Brightness brightness;
  CustomPreBuilder(this.brightness);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String codeText = element.textContent;
    if (codeText.endsWith('\n')) {
      codeText = codeText.substring(0, codeText.length - 1);
    }

    bool isDart = false;
    if (element.children != null && element.children!.isNotEmpty) {
      final child = element.children!.first;
      if (child is md.Element && child.attributes['class'] == 'language-dart') {
        isDart = true;
      }
    }

    final isDark = brightness == Brightness.dark;

    if (isDart) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.grey.shade300),
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            codeText,
            style: TextStyle(
              color: isDark ? const Color(0xFF9CDCFE) : const Color(0xFF3F51B5),
              fontFamily: 'monospace',
              fontSize: 14 * 0.9,
              height: 1.4,
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF332B00) : Colors.amber.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(
              color: isDark ? Colors.amber.shade700 : Colors.amber.shade800, 
              width: 5,
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            codeText,
            style: TextStyle(
              color: isDark ? Colors.amber.shade100 : Colors.amber.shade900,
              fontSize: 14,
              fontFamily: 'monospace', 
              fontWeight: FontWeight.normal,
              height: 1.5,
            ),
          ),
        ),
      );
    }
  }
}

// =================================================================
// 2. WIDGETS OPTIMIZADOS (EVITAN EL LAG Y PREVIENEN CRASHES)
// =================================================================

class LabWidget extends StatelessWidget {
  const LabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedLessonId = context.select<NotebookProvider, String?>((p) => p.selectedLesson?.id);
    final selectedLabWidget = context.select<NotebookProvider, Widget>((p) => p.selectedLabWidget);
    
    // Obtenemos el código fuente de la lección seleccionada
    final selectedLabCode = context.select<NotebookProvider, String>((p) => 
        p.selectedLesson?.labCode ?? 'Selecciona una lección para ver el código.');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey(selectedLessonId ?? 'initial'),
        color: Colors.transparent,
        
        // ¡LA MAGIA SUCEDE AQUÍ!
        // Si no hay lección elegida, mostramos el widget vacío. 
        // Si la hay, lo envolvemos en nuestro visor aislado de código.
        child: selectedLessonId == null 
            ? selectedLabWidget
            : LabCodeViewer(
                code: selectedLabCode,
                child: selectedLabWidget,
              ),
      ),
    );
  }
}

class TheoryWidget extends StatelessWidget {
  const TheoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isContentLoading = context.select<NotebookProvider, bool>((p) => p.isContentLoading);
    final selectedLessonId = context.select<NotebookProvider, String?>((p) => p.selectedLesson?.id);
    final markdownContent = context.select<NotebookProvider, String>((p) => p.markdownContent);
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: isContentLoading
          ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
          : _MarkdownScrollable(
              key: ValueKey(selectedLessonId ?? 'empty'),
              markdownData: markdownContent,
              theme: theme,
            ),
    );
  }
}

class _MarkdownScrollable extends StatefulWidget {
  final String markdownData;
  final ThemeData theme;
  const _MarkdownScrollable({super.key, required this.markdownData, required this.theme});

  @override
  State<_MarkdownScrollable> createState() => _MarkdownScrollableState();
}

class _MarkdownScrollableState extends State<_MarkdownScrollable> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;
    final bodyColor = isDark ? Colors.grey.shade300 : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: Markdown(
        controller: _scrollController,
        data: widget.markdownData,
        selectable: true,
        padding: const EdgeInsets.all(24),
        builders: {
          'pre': CustomPreBuilder(widget.theme.brightness),
        },
        styleSheet: MarkdownStyleSheet.fromTheme(widget.theme).copyWith(
          p: TextStyle(height: 1.5, fontSize: 15, color: bodyColor),
          h1: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          h2: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          h3: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          h4: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          h5: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          h6: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          code: TextStyle(
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade200,
            color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF3F51B5),
            fontFamily: 'monospace',
            fontSize: 14 * 0.9,
          ),
        ),
      ),
    );
  }
}

class SidebarWidget extends StatelessWidget {
  final bool isMobile;
  const SidebarWidget({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final lessons = context.select<NotebookProvider, List<Lesson>>((p) => p.lessons);
    final selectedLesson = context.select<NotebookProvider, Lesson?>((p) => p.selectedLesson);
    final theme = Theme.of(context);

    return _SidebarScrollable(
      lessons: lessons,
      selectedLesson: selectedLesson,
      isMobile: isMobile,
      theme: theme,
    );
  }
}

class _SidebarScrollable extends StatefulWidget {
  final List<Lesson> lessons;
  final Lesson? selectedLesson;
  final bool isMobile;
  final ThemeData theme;

  const _SidebarScrollable({
    required this.lessons,
    required this.selectedLesson,
    required this.isMobile,
    required this.theme,
  });

  @override
  State<_SidebarScrollable> createState() => _SidebarScrollableState();
}

class _SidebarScrollableState extends State<_SidebarScrollable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.theme.colorScheme;
    final isDark = widget.theme.brightness == Brightness.dark;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: widget.lessons.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lesson = widget.lessons[index];
          final isSelected = widget.selectedLesson == lesson;
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
                color: isSelected ? colorScheme.primary : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            onTap: () {
              context.read<NotebookProvider>().selectLesson(lesson);
              if (widget.isMobile) {
                Navigator.of(context).pop(); 
              }
            },
          );
        },
      ),
    );
  }
}

// =================================================================
// 3. PANTALLA PRINCIPAL
// =================================================================
class NotebookHomePage extends StatefulWidget {
  const NotebookHomePage({super.key});

  @override
  State<NotebookHomePage> createState() => _NotebookHomePageState();
}

class _NotebookHomePageState extends State<NotebookHomePage> {
  late MultiSplitViewController _splitController;
  int _mobileTabIndex = 0;
  bool _isDarkMode = false; 

  @override
  void initState() {
    super.initState();
    _splitController = MultiSplitViewController(
      areas: [
        Area(
          flex: 1, min: 0.15,
          builder: (context, area) => PanelCard(
            title: 'Índice de Lecciones',
            icon: Icons.list_alt_rounded,
            borderColor: Theme.of(context).colorScheme.primary,
            child: const SidebarWidget(isMobile: false),
          ),
        ),
        Area(
          flex: 1, min: 0.20,
          builder: (context, area) => PanelCard(
            title: 'Conceptos Teóricos',
            icon: Icons.article_outlined,
            borderColor: Theme.of(context).colorScheme.tertiary,
            child: const TheoryWidget(),
          ),
        ),
        Area(
          flex: 1, min: 0.20,
          builder: (context, area) => PanelCard(
            title: 'Laboratorio en Vivo',
            icon: Icons.science_outlined,
            borderColor: Theme.of(context).colorScheme.secondary,
            child: const LabWidget(),
          ),
        ),
      ],
    );
  }

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 10),
                  Text('Configuración'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.bold)),
                    secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
                    value: _isDarkMode,
                    onChanged: (bool value) {
                      setDialogState(() => _isDarkMode = value);
                      _toggleTheme(value);
                    },
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.language, color: Colors.grey),
                    title: Text('Idioma (próximamente)', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

    return Theme(
      data: activeTheme,
      child: Builder(
        builder: (context) {
          final isInitialLoading = context.select<NotebookProvider, bool>((p) => p.isInitialLoading);
          final error = context.select<NotebookProvider, String?>((p) => p.error);
          final isEmpty = context.select<NotebookProvider, bool>((p) => p.lessons.isEmpty);
          final lessonTitle = context.select<NotebookProvider, String>((p) => p.selectedLesson?.title ?? 'Cargando...');

          if (isInitialLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(child: CircularProgressIndicator())
            );
          }

          if (error != null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(title: const Text('Error de Carga')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ),
            );
          }

          if (isEmpty) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(child: Text("No se encontraron lecciones.")),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;

              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                appBar: AppBar(
                  title: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: 'Curso Web de Flutter: ',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: lessonTitle,
                          style: const TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  actions: [
                    // ==========================================
                    // ¡NUESTRO NUEVO BOTÓN DE BÚSQUEDA!
                    // ==========================================
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar Lección',
                      onPressed: () async {
                        // 1. Obtenemos las lecciones del provider
                        final provider = context.read<NotebookProvider>();
                        
                        // 2. Abrimos la pantalla transparente de búsqueda
                        final selectedLesson = await showSearch<Lesson?>(
                          context: context,
                          delegate: LessonSearchDelegate(provider.lessons),
                        );
                        
                        // 3. Si el usuario tocó un resultado, cargamos esa lección
                        if (selectedLesson != null && context.mounted) {
                          provider.selectLesson(selectedLesson);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Configuración',
                      onPressed: _showSettingsDialog,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                
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
                              child: const SidebarWidget(isMobile: true), 
                            ),
                          ),
                        ),
                      )
                    : null,

                bottomNavigationBar: isMobile
                    ? BottomNavigationBar(
                        currentIndex: _mobileTabIndex,
                        onTap: (index) => setState(() => _mobileTabIndex = index),
                        selectedItemColor: Colors.blue.shade900,
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Teoría'),
                          BottomNavigationBarItem(icon: Icon(Icons.science_outlined), label: 'Laboratorio'),
                        ],
                      )
                    : null,

                body: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                  child: isMobile ? _buildMobileBody(context) : _buildDesktopBody(context),
                ),
              );
            },
          );
        }
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 5,
        dividerPainter: DividerPainters.grooved1(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightedColor: Colors.blue,
        ),
      ),
      child: MultiSplitView(controller: _splitController),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return IndexedStack(
      index: _mobileTabIndex,
      children: [
        PanelCard(
          title: 'Conceptos Teóricos',
          icon: Icons.article_outlined,
          borderColor: Theme.of(context).colorScheme.tertiary,
          child: const TheoryWidget(), 
        ),
        PanelCard(
          title: 'Laboratorio en Vivo',
          icon: Icons.science_outlined,
          borderColor: Theme.of(context).colorScheme.secondary,
          child: const LabWidget(),
        ),
      ],
    );
  }
}