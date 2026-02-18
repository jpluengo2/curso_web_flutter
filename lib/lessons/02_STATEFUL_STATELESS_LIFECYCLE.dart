import 'package:flutter/material.dart';
import 'dart:async';

class Lab02StatefulStateless extends StatelessWidget {
  const Lab02StatefulStateless({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 02: Estado y Ciclo de Vida",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. STATELESS (ESTÁTICO) ---
        _buildSectionHeader("1. StatelessWidget (Inmutable)"),
        const Text("Estos widgets se pintan una vez y no cambian solos."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Tarjetas de Usuario (Datos fijos)",
          const Column(
            children: [
              UserCard(name: "Ana García", role: "Diseñadora", color: Colors.orange),
              SizedBox(height: 10),
              UserCard(name: "Carlos Ruiz", role: "Desarrollador", color: Colors.blue),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- 2. EJERCICIO: TODO LIST (LISTAS DINÁMICAS) ---
        _buildSectionHeader("2. StatefulWidget: Lista de Tareas"),
        const Text("Ejercicio 1: Añadir y eliminar elementos de una lista."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Mini Todo App",
          const TodoListDemo(),
        ),

        const SizedBox(height: 30),

        // --- 3. EJERCICIO: GALERÍA (SELECCIÓN) ---
        _buildSectionHeader("3. Estado de Selección"),
        const Text("Ejercicio 3: Galería interactiva. Toca un icono para ver detalles."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Galería Interactiva",
          const InteractiveGallery(),
        ),

        const SizedBox(height: 30),

        // --- 4. CICLO DE VIDA (LIFECYCLE) ---
        _buildSectionHeader("4. Ciclo de Vida (Lifecycle)"),
        const Text("Observa cómo se crean y destruyen los widgets."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Monitor de Ciclo de Vida",
          const LifecycleVisualizer(),
        ),
        
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Padding(padding: const EdgeInsets.all(15), child: content),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGETS DE EJEMPLO
// ==========================================

// 1. STATELESS EXAMPLE
class UserCard extends StatelessWidget {
  final String name;
  final String role;
  final Color color;

  const UserCard({super.key, required this.name, required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, foregroundColor: Colors.white, child: Text(name[0])),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// 2. TODO LIST DEMO (Ejercicio 1)
class TodoListDemo extends StatefulWidget {
  const TodoListDemo({super.key});
  @override
  State<TodoListDemo> createState() => _TodoListDemoState();
}

class _TodoListDemoState extends State<TodoListDemo> {
  final List<String> _tasks = ["Aprender Flutter", "Practicar Dart"];
  final TextEditingController _ctrl = TextEditingController();

  void _addTask() {
    if (_ctrl.text.isNotEmpty) {
      setState(() {
        _tasks.add(_ctrl.text);
        _ctrl.clear();
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: "Nueva tarea...",
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                onSubmitted: (_) => _addTask(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTask,
              icon: const Icon(Icons.add),
              tooltip: "Añadir",
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Lista
        Container(
          height: 150, // Altura fija para el scroll interno
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: _tasks.isEmpty
              ? const Center(child: Text("Sin tareas", style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: _tasks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      title: Text(_tasks[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _removeTask(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// 3. GALERÍA INTERACTIVA (Ejercicio 3)
class InteractiveGallery extends StatefulWidget {
  const InteractiveGallery({super.key});
  @override
  State<InteractiveGallery> createState() => _InteractiveGalleryState();
}

class _InteractiveGalleryState extends State<InteractiveGallery> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _items = [
    {"icon": Icons.beach_access, "label": "Playa", "color": Colors.orange},
    {"icon": Icons.forest, "label": "Bosque", "color": Colors.green},
    {"icon": Icons.snowboarding, "label": "Nieve", "color": Colors.blue},
    {"icon": Icons.volcano, "label": "Volcán", "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grid de iconos
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = _selectedIndex == index;
            return InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? (item["color"] as Color).withOpacity(0.2) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? (item["color"] as Color) : Colors.grey.shade300,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item["icon"] as IconData,
                  color: isSelected ? (item["color"] as Color) : Colors.grey,
                  size: 30,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // Panel de detalles
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _selectedIndex == null
              ? const Center(child: Text("Selecciona un icono arriba"))
              : Column(
                  children: [
                    Icon(_items[_selectedIndex!]["icon"] as IconData, size: 50, color: _items[_selectedIndex!]["color"] as Color),
                    const SizedBox(height: 5),
                    Text(
                      _items[_selectedIndex!]["label"] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text("Elemento seleccionado dinámicamente"),
                  ],
                ),
        ),
      ],
    );
  }
}

// 4. LIFECYCLE VISUALIZER (Para entender initState/dispose)
class LifecycleVisualizer extends StatefulWidget {
  const LifecycleVisualizer({super.key});
  @override
  State<LifecycleVisualizer> createState() => _LifecycleVisualizerState();
}

class _LifecycleVisualizerState extends State<LifecycleVisualizer> {
  bool _showChild = false;
  final List<String> _logs = [];

  void _addLog(String msg) {
    // Usamos addPostFrameCallback para evitar errores de setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _logs.insert(0, "${DateTime.now().second}s: $msg"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Montar/Desmontar Widget"),
          value: _showChild,
          onChanged: (v) => setState(() {
            _showChild = v;
            if (!v) _addLog("🗑️ Padre eliminó el widget hijo");
            if (v) _addLog("✨ Padre creó el widget hijo");
          }),
        ),
        const Divider(),
        // Área del widget hijo
        Container(
          height: 80,
          alignment: Alignment.center,
          color: Colors.grey.shade100,
          child: _showChild
              ? ChildLifecycleWidget(onLog: _addLog)
              : const Text("Widget no existe en memoria"),
        ),
        const Divider(),
        // Consola de logs
        Container(
          height: 100,
          width: double.infinity,
          color: Colors.black87,
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: _logs.length,
            itemBuilder: (_, i) => Text(
              _logs[i], 
              style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 11)
            ),
          ),
        ),
      ],
    );
  }
}

class ChildLifecycleWidget extends StatefulWidget {
  final Function(String) onLog;
  const ChildLifecycleWidget({super.key, required this.onLog});

  @override
  State<ChildLifecycleWidget> createState() => _ChildLifecycleWidgetState();
}

class _ChildLifecycleWidgetState extends State<ChildLifecycleWidget> {
  @override
  void initState() {
    super.initState();
    widget.onLog("🟢 initState() llamado: Widget creado");
  }

  @override
  void dispose() {
    widget.onLog("🔴 dispose() llamado: Limpiando recursos...");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text(
      "¡Soy un Widget Vivo!",
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }
}