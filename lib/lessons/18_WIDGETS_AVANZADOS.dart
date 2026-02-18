import 'package:flutter/material.dart';

class Lab18WidgetsAvanzados extends StatelessWidget {
  const Lab18WidgetsAvanzados({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 18: Widgets Avanzados", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. PAGEVIEW ---
        _buildSectionHeader("1. PageView (Tutoriales/Sliders)"),
        _buildExampleCard("Slider con Indicador", const PageViewDemo()),
        const SizedBox(height: 30),

        // --- 2. SLIVERS ---
        _buildSectionHeader("2. Slivers (Scroll Effects)"),
        const Text("Efectos de scroll avanzados dentro de un área limitada."),
        const SizedBox(height: 10),
        _buildExampleCard("CustomScrollView & SliverAppBar", const SliversDemo()),
        const SizedBox(height: 30),

        // --- 3. DATATABLE ---
        _buildSectionHeader("3. DataTable (Tablas)"),
        _buildExampleCard("Tabla de Datos Interactiva", const DataTableDemo()),
        const SizedBox(height: 30),

        // --- 4. EXPANSION TILE ---
        _buildSectionHeader("4. ExpansionTile (Acordeón)"),
        _buildExampleCard("Listas Desplegables", const ExpansionDemo()),
        const SizedBox(height: 30),

        // --- 5. DRAGGABLE SHEET ---
        _buildSectionHeader("5. DraggableScrollableSheet"),
        const Text("Panel inferior deslizable (tipo Google Maps)."),
        const SizedBox(height: 10),
        _buildExampleCard("Hoja Deslizable", const DraggableSheetDemo()),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. PAGEVIEW DEMO
class PageViewDemo extends StatefulWidget {
  const PageViewDemo({super.key});
  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}
class _PageViewDemoState extends State<PageViewDemo> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              Container(color: Colors.blue.shade100, child: const Center(child: Text("Página 1: Bienvenida"))),
              Container(color: Colors.green.shade100, child: const Center(child: Text("Página 2: Instrucciones"))),
              Container(color: Colors.orange.shade100, child: const Center(child: Text("Página 3: Empezar"))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10, height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == index ? Colors.blue : Colors.grey),
              )),
            ),
          )
        ],
      ),
    );
  }
}

// 2. SLIVERS DEMO
class SliversDemo extends StatelessWidget {
  const SliversDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Sliver AppBar", style: TextStyle(color: Colors.black87, fontSize: 16)),
              background: Container(color: Colors.teal.shade100, child: const Icon(Icons.image, size: 50, color: Colors.white)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text("Elemento Sliver #$index"), leading: const Icon(Icons.label)),
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// 3. DATATABLE DEMO
class DataTableDemo extends StatelessWidget {
  const DataTableDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("ID")),
          DataColumn(label: Text("Nombre")),
          DataColumn(label: Text("Rol")),
        ],
        rows: const [
          DataRow(cells: [DataCell(Text("1")), DataCell(Text("Ana")), DataCell(Text("Admin"))]),
          DataRow(cells: [DataCell(Text("2")), DataCell(Text("Luis")), DataCell(Text("User"))]),
          DataRow(cells: [DataCell(Text("3")), DataCell(Text("Eva")), DataCell(Text("Editor"))]),
        ],
      ),
    );
  }
}

// 4. EXPANSION DEMO
class ExpansionDemo extends StatelessWidget {
  const ExpansionDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ExpansionTile(
          title: Text("Opciones Avanzadas"),
          leading: Icon(Icons.settings),
          children: [
            ListTile(title: Text("Opción A")),
            ListTile(title: Text("Opción B")),
          ],
        ),
        ExpansionTile(
          title: Text("Ayuda y Soporte"),
          leading: Icon(Icons.help),
          children: [
            Padding(padding: EdgeInsets.all(10), child: Text("Aquí va el texto de ayuda desplegable...")),
          ],
        ),
      ],
    );
  }
}

// 5. DRAGGABLE SHEET DEMO
class DraggableSheetDemo extends StatelessWidget {
  const DraggableSheetDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(color: Colors.blueGrey.shade100, child: const Center(child: Text("Mapa de fondo (Simulado)"))),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 20,
                  itemBuilder: (context, index) => ListTile(title: Text("Lugar cercano $index"), leading: const Icon(Icons.place, color: Colors.red)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}