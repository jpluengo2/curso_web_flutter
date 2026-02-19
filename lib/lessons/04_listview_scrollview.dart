import 'package:flutter/material.dart';

class Lab04ListViews extends StatelessWidget {
  const Lab04ListViews({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 04: Listas y Scroll Avanzado",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. LISTAS BÁSICAS ---
        _buildSectionHeader("1. Orientación del Scroll"),
        _buildExampleCard(
          "Vertical y Horizontal",
          const BasicListsDemo(),
        ),

        const SizedBox(height: 30),

        // --- 2. GRID VIEW ---
        _buildSectionHeader("2. GridView (Cuadrículas)"),
        _buildExampleCard(
          "Galería Responsive (fixed cross axis)",
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.teal[100 * ((index % 8) + 1)],
                  child: Center(child: Text("${index + 1}", style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold))),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 3. INFINITE SCROLL & REFRESH ---
        _buildSectionHeader("3. Infinite Scroll & Refresh"),
        const Text("Desliza hacia abajo para recargar o llega al final para cargar más."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Carga perezosa de datos",
          const InfiniteListDemo(),
        ),

        const SizedBox(height: 30),

        // --- 4. LISTA REORDENABLE ---
        _buildSectionHeader("4. ReorderableListView"),
        const Text("Mantén pulsado un elemento para moverlo."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Lista de Tareas (Drag & Drop)",
          const ReorderableListDemo(),
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

// 1. LISTAS BÁSICAS
class BasicListsDemo extends StatelessWidget {
  const BasicListsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Horizontal (Instagram Stories):", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50, 
                  border: Border.all(color: Colors.purple.shade100),
                  shape: BoxShape.circle
                ),
                child: Center(child: Text("#$index")),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        const Text("Vertical (Separated):", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        SizedBox(
          height: 120,
          child: ListView.separated(
            itemCount: 20,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => ListTile(
              dense: true,
              leading: const Icon(Icons.label_outline, size: 18),
              title: Text("Elemento de lista $index"),
            ),
          ),
        ),
      ],
    );
  }
}

// 2. INFINITE SCROLL DEMO
class InfiniteListDemo extends StatefulWidget {
  const InfiniteListDemo({super.key});
  @override
  State<InfiniteListDemo> createState() => _InfiniteListDemoState();
}

class _InfiniteListDemoState extends State<InfiniteListDemo> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _items = List.generate(15, (index) => "Item original $index");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Si llegamos al final (maxScrollExtent) y no estamos cargando...
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 && !_isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simular API
    setState(() {
      _items.addAll(List.generate(5, (index) => "Item Nuevo ${_items.length + index}"));
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _items.clear();
      _items.addAll(List.generate(15, (index) => "Item Refrescado $index"));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + 1, // +1 para el loader final
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return _isLoading 
                    ? const Padding(padding: EdgeInsets.all(10), child: Center(child: CircularProgressIndicator()))
                    : const SizedBox.shrink();
                }
                return ListTile(title: Text(_items[index]));
              },
            ),
          ),
        ),
        // Botones de control
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () => _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeOut),
              tooltip: "Ir arriba",
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () => _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.easeOut),
              tooltip: "Ir abajo",
            ),
          ],
        )
      ],
    );
  }
}

// 3. REORDERABLE LIST DEMO
class ReorderableListDemo extends StatefulWidget {
  const ReorderableListDemo({super.key});
  @override
  State<ReorderableListDemo> createState() => _ReorderableListDemoState();
}

class _ReorderableListDemoState extends State<ReorderableListDemo> {
  final List<String> _todos = ["Comprar leche", "Pasear al perro", "Estudiar Flutter", "Hacer ejercicio"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ReorderableListView(
        children: [
          for (int index = 0; index < _todos.length; index++)
            ListTile(
              key: Key('$index'), // Importante: Key única
              title: Text(_todos[index]),
              leading: const Icon(Icons.drag_handle),
              tileColor: index.isEven ? Colors.grey.shade50 : Colors.white,
            ),
        ],
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final String item = _todos.removeAt(oldIndex);
            _todos.insert(newIndex, item);
          });
        },
      ),
    );
  }
}