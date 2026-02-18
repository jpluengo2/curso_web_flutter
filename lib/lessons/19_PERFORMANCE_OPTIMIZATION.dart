import 'package:flutter/material.dart';
import 'dart:math';

class Lab19Performance extends StatelessWidget {
  const Lab19Performance({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 19: Optimización y Rendimiento", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. REBUILD TRACKER ---
        _buildSectionHeader("1. Costo de Reconstrucción (Build Cost)"),
        const Text("Este ejemplo muestra cuántas veces se redibuja un widget. Usa 'const' para evitarlo."),
        const SizedBox(height: 10),
        _buildExampleCard("Monitor de Rebuilds", const RebuildTrackerDemo()),
        const SizedBox(height: 30),

        // --- 2. LISTAS OPTIMIZADAS ---
        _buildSectionHeader("2. Listas: ListView vs ListView.builder"),
        const Text("Diferencia de memoria entre cargar todo (Bad) vs Lazy Loading (Good)."),
        const SizedBox(height: 10),
        _buildExampleCard("Lista Gigante Optimizada", const OptimizedListDemo()),
        const SizedBox(height: 30),

        // --- 3. REPAINT BOUNDARY ---
        _buildSectionHeader("3. RepaintBoundary"),
        const Text("Aísla animaciones complejas para que no obliguen a repintar toda la pantalla."),
        const SizedBox(height: 10),
        _buildExampleCard("Aislamiento de Pintado", const RepaintBoundaryDemo()),
        const SizedBox(height: 30),

        // --- 4. OPACITY VS ANIMATED OPACITY ---
        _buildSectionHeader("4. Opacity Costoso vs Eficiente"),
        const Text("AnimatedOpacity es más eficiente que cambiar la opacidad en un build loop."),
        const SizedBox(height: 10),
        _buildExampleCard("Transparencia Eficiente", const OpacityDemo()),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. REBUILD TRACKER DEMO
class RebuildTrackerDemo extends StatefulWidget {
  const RebuildTrackerDemo({super.key});
  @override
  State<RebuildTrackerDemo> createState() => _RebuildTrackerDemoState();
}
class _RebuildTrackerDemoState extends State<RebuildTrackerDemo> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: () => setState(() => _counter++), child: Text("Forzar Rebuild Global (Count: $_counter)")),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Widget que NO es const -> Se reconstruye
            _HeavyWidget(isConst: false),
            // Widget que SÍ es const -> NO se reconstruye
            _HeavyWidget(isConst: true),
          ],
        )
      ],
    );
  }
}

class _HeavyWidget extends StatelessWidget {
  final bool isConst;
  // Truco: Generamos un color aleatorio EN EL CONSTRUCTOR si no es const para evidenciar el rebuild
  final Color color;

  // ignore: prefer_const_constructors_in_immutables
  _HeavyWidget({super.key, required this.isConst}) : color = Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  Widget build(BuildContext context) {
    // Si es const, Flutter usa la instancia cacheada y no ejecuta build() de nuevo
    return Container(
      width: 100, height: 100,
      color: isConst ? Colors.grey : color, // Gris fijo si es const, Discoteca si no lo es
      alignment: Alignment.center,
      child: Text(isConst ? "SOY CONST\n(Estático)" : "NO CONST\n(Rebuild!)", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

// 2. OPTIMIZED LIST DEMO
class OptimizedListDemo extends StatelessWidget {
  const OptimizedListDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        // 'itemExtent' mejora drásticamente el performance al evitar calcular alturas
        itemExtent: 50, 
        itemCount: 10000, // 10 mil elementos
        itemBuilder: (context, index) {
          // Solo se crean los que caben en pantalla
          return ListTile(
            dense: true,
            title: Text("Elemento #$index (Lazy Loaded)"),
            leading: const Icon(Icons.bolt, color: Colors.amber),
          );
        },
      ),
    );
  }
}

// 3. REPAINT BOUNDARY DEMO
class RepaintBoundaryDemo extends StatefulWidget {
  const RepaintBoundaryDemo({super.key});
  @override
  State<RepaintBoundaryDemo> createState() => _RepaintBoundaryDemoState();
}
class _RepaintBoundaryDemoState extends State<RepaintBoundaryDemo> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("El spinner rota infinitamente. Sin RepaintBoundary, repintaría el fondo estático también."),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 200, height: 100, color: Colors.blue.shade50),
            // Aislamos la rotación
            RepaintBoundary(
              child: RotationTransition(
                turns: _ctrl,
                child: Container(width: 50, height: 50, color: Colors.blue),
              ),
            ),
          ],
        )
      ],
    );
  }
}

// 4. OPACITY DEMO
class OpacityDemo extends StatefulWidget {
  const OpacityDemo({super.key});
  @override
  State<OpacityDemo> createState() => _OpacityDemoState();
}
class _OpacityDemoState extends State<OpacityDemo> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: () => setState(() => _visible = !_visible), child: const Text("Alternar Visibilidad")),
        const SizedBox(height: 10),
        // AnimatedOpacity es mucho más eficiente que un widget Opacity dentro de un AnimationController
        AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Container(width: 100, height: 50, color: Colors.green, child: const Center(child: Text("Eficiente", style: TextStyle(color: Colors.white)))),
        )
      ],
    );
  }
}