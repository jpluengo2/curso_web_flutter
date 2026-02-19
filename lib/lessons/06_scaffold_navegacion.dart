import 'package:flutter/material.dart';

class Lab06Scaffold extends StatelessWidget {
  const Lab06Scaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 06: Scaffold y Estructura",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. APP BAR CLÁSICO ---
        _buildSectionHeader("1. AppBar y Actions"),
        _buildExampleCard(
          "AppBar con Gradiente y Botones de Acción",
          SizedBox(
            height: 200,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Mi App'),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  // Avatar de usuario
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: CircleAvatar(backgroundColor: Colors.white24, child: Text("A")),
                  )
                ],
              ),
              body: const Center(child: Text("El cuerpo del Scaffold")),
              floatingActionButton: FloatingActionButton(
                mini: true,
                child: const Icon(Icons.add),
                onPressed: () {},
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 2. DRAWERS (IZQUIERDA Y DERECHA) ---
        _buildSectionHeader("2. Drawers (Menús Laterales)"),
        const Text("Prueba a abrir el menú de la izquierda (Navegación) y el de la derecha (Filtros)."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Drawer y EndDrawer",
          SizedBox(
            height: 350,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Menús Laterales"), 
                backgroundColor: Colors.teal,
              ),
              // MENÚ IZQUIERDO (Principal)
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: const [
                    UserAccountsDrawerHeader(
                      accountName: Text("Flutter Dev"),
                      accountEmail: Text("alumno@flutter.com"),
                      currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Text("F")),
                      decoration: BoxDecoration(color: Colors.teal),
                    ),
                    ListTile(leading: Icon(Icons.home), title: Text("Inicio")),
                    ListTile(leading: Icon(Icons.settings), title: Text("Ajustes")),
                  ],
                ),
              ),
              // MENÚ DERECHO (Secundario/Filtros)
              endDrawer: Drawer(
                child: Column(
                  children: [
                    AppBar(title: const Text("Filtros"), automaticallyImplyLeading: false, backgroundColor: Colors.grey),
                    const ListTile(title: Text("Ordenar por fecha"), trailing: Icon(Icons.sort)),
                    const ListTile(title: Text("Mostrar ocultos"), trailing: Icon(Icons.visibility_off)),
                  ],
                ),
              ),
              body: Builder(
                builder: (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.menu),
                        label: const Text("Abrir Menú Izquierdo"),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.filter_list),
                        label: const Text("Abrir Menú Derecho"),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 3. BOTTOM APP BAR (DOCKED FAB) ---
        _buildSectionHeader("3. BottomAppBar con FAB Incrustado"),
        _buildExampleCard(
          "Diseño moderno con 'Notch' (Muesca)",
          SizedBox(
            height: 250,
            child: Scaffold(
              backgroundColor: Colors.grey.shade200,
              body: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, i) => Card(margin: const EdgeInsets.all(5), child: ListTile(title: Text("Elemento $i"))),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(), // La magia del recorte
                notchMargin: 8.0,
                color: Colors.indigo,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                    const SizedBox(width: 40), // Espacio para el FAB
                    IconButton(icon: const Icon(Icons.favorite, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 4. TABS ---
        _buildSectionHeader("4. TabBar (Pestañas)"),
        _buildExampleCard(
          "Navegación por pestañas",
          SizedBox(
            height: 300,
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.deepOrange,
                  title: const Text("Mis Viajes"),
                  bottom: const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    tabs: [
                      Tab(icon: Icon(Icons.flight), text: "Vuelos"),
                      Tab(icon: Icon(Icons.hotel), text: "Hoteles"),
                      Tab(icon: Icon(Icons.map), text: "Mapa"),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    Center(child: Icon(Icons.flight, size: 60, color: Colors.deepOrange)),
                    Center(child: Icon(Icons.hotel, size: 60, color: Colors.deepOrange)),
                    Center(child: Icon(Icons.map, size: 60, color: Colors.deepOrange)),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 5. SLIVER APP BAR (COLLAPSING) ---
        _buildSectionHeader("5. SliverAppBar (Efecto Colapsable)"),
        const Text("Haz scroll hacia abajo dentro del recuadro para ver el efecto."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "CustomScrollView con SliverAppBar",
          SizedBox(
            height: 300,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 150.0,
                    floating: false,
                    pinned: true, // Se queda fija arriba al hacer scroll
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text("Sliver Effect"),
                      background: Container(
                        color: Colors.blueGrey,
                        child: const Icon(Icons.image, size: 80, color: Colors.white24),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return ListTile(
                          title: Text('Elemento de lista #$index'),
                        );
                      },
                      childCount: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 6. FEEDBACK & SHEETS ---
        _buildSectionHeader("6. Feedback e Interacción"),
        _buildExampleCard(
          "BottomSheet Modal y Persistente",
          const FeedbackDemo(),
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

class FeedbackDemo extends StatelessWidget {
  const FeedbackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.info_outline),
          label: const Text("Mostrar SnackBar"),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("¡Hola! Soy un SnackBar flotante"),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(label: "Cerrar", onPressed: () {}),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text("BottomSheet Modal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text("Bloquea el contenido de atrás."),
                        const Spacer(),
                        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
                      ],
                    ),
                  ),
                );
              },
              child: const Text("Modal Sheet"),
            ),
            const SizedBox(width: 10),
            // Nota: El PersistentBottomSheet necesita un GlobalKey del Scaffold o usarse dentro del body
            // Para simplificar en este entorno, simulamos el concepto.
             ElevatedButton(
              onPressed: () {
                 showDialog(
                   context: context, 
                   builder: (_) => const AlertDialog(
                     title: Text("Dialog"), 
                     content: Text("Soy un diálogo modal estándar.")
                   )
                 );
              },
              child: const Text("Dialog Alert"),
            ),
          ],
        ),
      ],
    );
  }
}