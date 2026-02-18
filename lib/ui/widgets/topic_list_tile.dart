import 'package:flutter/material.dart';

/// Un widget que representa un elemento en la lista de temas.
class TopicListTile extends StatelessWidget {
  final String topicPath;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicListTile({
    super.key,
    required this.topicPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extraemos el nombre del fichero para mostrarlo.
    final String title = topicPath.split('/').last.replaceAll('.md', '');

    return ListTile(
      title: Text(title),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
    );
  }
}