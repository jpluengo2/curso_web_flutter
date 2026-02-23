import 'package:flutter/material.dart';
import '../../models/lesson_model.dart';

/// Clase que construye la interfaz nativa de búsqueda superpuesta
class LessonSearchDelegate extends SearchDelegate<Lesson?> {
  final List<Lesson> lessons;

  LessonSearchDelegate(this.lessons) : super(
    searchFieldLabel: 'Buscar concepto (ej. "StatefulWidget")...',
  );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = ''; 
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); 
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsList(context);
  }

  // --- LÓGICA DE BÚSQUEDA PROFUNDA ---
  Widget _buildSuggestionsList(BuildContext context) {
    // Si no ha escrito nada, le mostramos una ayuda
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Escribe un concepto para buscar en toda la teoría.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final queryLower = query.toLowerCase();

    // 1. FILTRADO PROFUNDO: Busca en título, ID y en todo el TEXTO (content)
    final filteredLessons = lessons.where((lesson) {
      final titleLower = lesson.title.toLowerCase();
      final idLower = lesson.id.toLowerCase();
      final contentLower = lesson.content.toLowerCase();
      
      return titleLower.contains(queryLower) || 
             idLower.contains(queryLower) ||
             contentLower.contains(queryLower);
    }).toList();

    if (filteredLessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No se encontró este concepto en ninguna lección.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 2. DIBUJAR RESULTADOS
    return ListView.builder(
      itemCount: filteredLessons.length,
      itemBuilder: (context, index) {
        final lesson = filteredLessons[index];
        final theme = Theme.of(context);
        
        // Comprobamos si la palabra estaba en el título o solo escondida en la teoría
        final bool foundInTitle = lesson.title.toLowerCase().contains(queryLower) || 
                                  lesson.id.toLowerCase().contains(queryLower);
        
        return ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Text(
              lesson.id, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: theme.colorScheme.primary
              )
            ),
          ),
          title: Text(lesson.title),
          // DETALLE UX: Si lo encontró en la teoría pero no en el título, le avisamos
          subtitle: (!foundInTitle) 
              ? Text(
                  'Concepto encontrado en la teoría', 
                  style: TextStyle(
                    color: theme.colorScheme.secondary, 
                    fontSize: 12, 
                    fontStyle: FontStyle.italic
                  )
                )
              : null,
          onTap: () {
            close(context, lesson); 
          },
        );
      },
    );
  }
}