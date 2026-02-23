import 'package:flutter/material.dart';
// LIBRERÍAS OFICIALES DE MARKDOWN
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';

import '../../providers/notebook_provider.dart';
import '../../config/app_theme.dart';
import '../widgets/panel_card.dart';

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
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            codeText,
            style: TextStyle(
              color: isDark ? Colors.blue.shade300 : const Color(0xFF3F51B5),
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
          color: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(
              color: isDark ? Colors.amber.shade600 : Colors.amber.shade800, 
              width: 5,
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            codeText,
            style: TextStyle(
              color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
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
// 2. PANTALLA PRINCIPAL
// =================================================================
class NotebookHomePage extends StatefulWidget {
  const NotebookHomePage({super.key});

  @override
  State<NotebookHomePage> createState() => _NotebookHomePageState();
}

class _NotebookHomePageState extends State<NotebookHomePage> {
  late MultiSplitViewController _splitController;

  final ScrollController _listScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();

  int _mobileTabIndex = 0;
  
  bool _isDarkMode = false; 

  @override
  void initState() {
    super.initState();
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

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
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
                  // NUEVO DISEÑO DEL IDIOMA: Línea simple, en gris y no interactiva
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
          final provider = context.watch<NotebookProvider>();

          if (provider.isInitialLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(child: CircularProgressIndicator())
            );
          }

          if (provider.error != null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(child: Text("No se encontraron lecciones en assets/markdown/")),
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
                  actions: [
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
                              child: _buildSidebarContent(isMobile: true), 
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
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 5,
        dividerPainter: DividerPainters.grooved1(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade800 
              : Colors.grey.shade300,
          highlightedColor: Colors.blue,
        ),
      ),
      child: MultiSplitView(
        controller: _splitController,
      ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  builders: {
                    'pre': CustomPreBuilder(theme.brightness),
                  },
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    p: const TextStyle(height: 1.5, fontSize: 15),
                    code: TextStyle(
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      color: isDark ? Colors.blue.shade300 : const Color(0xFF3F51B5),
                      fontFamily: 'monospace',
                      fontSize: 14 * 0.9,
                    ),
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