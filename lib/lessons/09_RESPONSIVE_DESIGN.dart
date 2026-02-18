import 'package:flutter/material.dart';

class Lab09Responsive extends StatelessWidget {
  const Lab09Responsive({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 09: Diseño Responsivo",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. MEDIA QUERY & LAYOUT BUILDER ---
        _buildSectionHeader("1. Diagnóstico de Pantalla"),
        const Text("Arrastra el divisor central para cambiar el ancho y ver cómo reaccionan los widgets."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Monitor de Dimensiones",
          const DimensionsMonitor(),
        ),

        const SizedBox(height: 30),

        // --- 2. FLEXIBILIDAD (Flexible/Expanded) ---
        _buildSectionHeader("2. Flexible vs Expanded"),
        const Text("Cómo se distribuye el espacio en una fila."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Distribución Proporcional (Flex)",
          const FlexLayoutDemo(),
        ),

        const SizedBox(height: 30),

        // --- 3. PATRÓN 1: LISTA VS GRID ---
        _buildSectionHeader("3. Patrón Adaptativo: Lista/Grid"),
        const Text("Si el ancho < 400px muestra Lista, si es mayor muestra Grid."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Cambio de Layout Dinámico",
          const ListGridSwitcher(),
        ),

        const SizedBox(height: 30),

        // --- 4. SAFE AREA SIMULATOR ---
        _buildSectionHeader("4. Safe Area"),
        const Text("Simulación de un dispositivo con 'Notch' para ver la utilidad de SafeArea."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Simulador de Notch",
          const SafeAreaSimulator(),
        ),

        const SizedBox(height: 30),

        // --- 5. PATRÓN MASTER-DETAIL ---
        _buildSectionHeader("5. Patrón Master-Detail"),
        const Text("Típico en Tablets: Muestra lista y detalles juntos si hay espacio."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Master-Detail Responsivo",
          const SizedBox(
            height: 350,
            child: MasterDetailLayout(),
          ),
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
// DEMOS INTERACTIVOS
// ==========================================

// 1. MONITOR DE DIMENSIONES (Usando LayoutBuilder)
class DimensionsMonitor extends StatelessWidget {
  const DimensionsMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nos da el tamaño del widget PADRE (el panel), no de toda la pantalla
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isNarrow = width < 300;
        final color = width < 300 ? Colors.orange : (width < 500 ? Colors.blue : Colors.green);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                isNarrow ? Icons.phone_android : (width < 500 ? Icons.tablet : Icons.desktop_windows),
                size: 40, 
                color: color
              ),
              const SizedBox(height: 10),
              Text(
                "Ancho del Panel: ${width.toStringAsFixed(1)} px",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.withOpacity(1)),
              ),
              Text(
                width < 300 ? "Vista Móvil Estrecha" : (width < 500 ? "Vista Tablet/Compacta" : "Vista Escritorio"),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 2. FLEX LAYOUT DEMO
class FlexLayoutDemo extends StatelessWidget {
  const FlexLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Row con Expanded (Flex 1, 2, 1)"),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(flex: 1, child: _colorBox(Colors.red, "1", "25%")),
            Expanded(flex: 2, child: _colorBox(Colors.blue, "2", "50%")),
            Expanded(flex: 1, child: _colorBox(Colors.green, "1", "25%")),
          ],
        ),
        const SizedBox(height: 15),
        const Text("Spacer (Hueco flexible)"),
        const SizedBox(height: 5),
        Row(
          children: [
            _fixedBox(Colors.purple, "Fijo"),
            const Spacer(), // Empuja los widgets a los extremos
            _fixedBox(Colors.purple, "Fijo"),
          ],
        )
      ],
    );
  }

  Widget _colorBox(Color color, String flex, String pct) {
    return Container(
      height: 50,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Flex: $flex", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(pct, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _fixedBox(Color color, String text) {
    return Container(
      height: 50,
      width: 60,
      color: color,
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

// 3. LIST VS GRID SWITCHER
class ListGridSwitcher extends StatelessWidget {
  const ListGridSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para decidir qué widget retornar
    return LayoutBuilder(
      builder: (context, constraints) {
        // BREAKPOINT: 400 pixels
        bool isWide = constraints.maxWidth > 400;

        if (!isWide) {
          // MODO LISTA (Pantalla estrecha)
          return SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Contacto $index"),
                  subtitle: const Text("Vista de Lista (Estrecho)"),
                ),
              ),
            ),
          );
        } else {
          // MODO GRID (Pantalla ancha)
          return SizedBox(
            height: 200,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              children: List.generate(6, (index) => Card(
                color: Colors.teal.shade50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 30, color: Colors.teal),
                    Text("Grid $index"),
                    const Text("Ancho", style: TextStyle(fontSize: 10)),
                  ],
                ),
              )),
            ),
          );
        }
      },
    );
  }
}

// 4. SIMULADOR DE SAFE AREA
class SafeAreaSimulator extends StatefulWidget {
  const SafeAreaSimulator({super.key});
  @override
  State<SafeAreaSimulator> createState() => _SafeAreaSimulatorState();
}

class _SafeAreaSimulatorState extends State<SafeAreaSimulator> {
  bool _useSafeArea = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(_useSafeArea ? "SafeArea: ACTIVADO" : "SafeArea: DESACTIVADO"),
          subtitle: const Text("Evita la intrusión del notch"),
          value: _useSafeArea,
          onChanged: (v) => setState(() => _useSafeArea = v),
        ),
        const SizedBox(height: 10),
        // Marco del teléfono simulado
        Container(
          height: 200,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey, width: 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // PANTALLA SIMULADA
                Container(
                  color: Colors.white,
                  child: _useSafeArea 
                    // Simulamos lo que hace SafeArea internamente añadiendo padding
                    ? Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 10), // Padding simulado
                        child: _buildAppContent(),
                      )
                    : _buildAppContent(),
                ),
                // EL "NOTCH" (Muesca física)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 25,
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                  ),
                ),
                // LA BARRA DE INICIO (iOS Home Indicator)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    height: 4,
                    width: 100,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppContent() {
    return Container(
      color: Colors.blue.shade100,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            color: Colors.blue,
            width: double.infinity,
            child: const Text("Mi App Header", style: TextStyle(color: Colors.white)),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Si SafeArea está OFF, este texto y el header quedan tapados por el 'notch' negro."),
          ),
        ],
      ),
    );
  }
}

// 5. MASTER-DETAIL LAYOUT (Tablet Pattern)
class MasterDetailLayout extends StatefulWidget {
  const MasterDetailLayout({super.key});
  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  int? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint para Tablet
        bool isTablet = constraints.maxWidth > 500;

        if (isTablet) {
          // --- MODO TABLET: LADO A LADO ---
          return Row(
            children: [
              // Panel Izquierdo (Lista)
              SizedBox(
                width: 150,
                child: _buildList(),
              ),
              const VerticalDivider(width: 1),
              // Panel Derecho (Detalle)
              Expanded(
                child: _selectedItem == null 
                  ? const Center(child: Text("Selecciona un item"))
                  : _buildDetail(_selectedItem!),
              ),
            ],
          );
        } else {
          // --- MODO MÓVIL: NAVEGACIÓN ---
          // Si hay selección, mostramos detalle (simulando nueva pantalla)
          if (_selectedItem != null) {
            return Column(
              children: [
                AppBar(
                  title: const Text("Detalle"),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _selectedItem = null),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.blue.shade50,
                ),
                Expanded(child: _buildDetail(_selectedItem!)),
              ],
            );
          }
          // Si no, mostramos lista
          return _buildList();
        }
      },
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("Item $index"),
          selected: _selectedItem == index,
          onTap: () => setState(() => _selectedItem = index),
          trailing: const Icon(Icons.chevron_right, size: 16),
        );
      },
    );
  }

  Widget _buildDetail(int index) {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info, size: 50, color: Colors.blue.shade800),
          const SizedBox(height: 20),
          Text("Detalles del Item $index", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Aquí iría la descripción completa del elemento seleccionado...", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}