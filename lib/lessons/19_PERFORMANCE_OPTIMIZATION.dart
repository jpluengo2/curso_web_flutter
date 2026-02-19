import 'package:flutter/material.dart';
import 'dart:math';

class Lab19PerformanceOptimization extends StatelessWidget {
  const Lab19PerformanceOptimization({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 19: Optimización y Rendimiento",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // --- 1. REBUILD TRACKER ---
        _buildSectionHeader(context, "1. Costo de Reconstrucción (Build Cost)"),
        const Text("Este ejemplo muestra cómo un widget 'const' evita reconstruirse, mientras que uno normal se redibuja con cada cambio de estado del padre."),
        const SizedBox(height: 10),
        _buildExampleCard(context, "Monitor de Rebuilds", const RebuildTrackerDemo()),
        const SizedBox(height: 30),

        // --- 2. LISTAS OPTIMIZADAS ---
        _buildSectionHeader(context, "2. Listas: ListView vs ListView.builder"),
        const Text("Diferencia de memoria entre cargar todo (Bad) vs Lazy Loading (Good)."),
        const SizedBox(height: 10),
        _buildExampleCard(context, "Lista Gigante Optimizada", const OptimizedListDemo()),
        const SizedBox(height: 30),

        // --- 3. REPAINT BOUNDARY ---
        _buildSectionHeader(context, "3. RepaintBoundary"),
        const Text("Aísla animaciones complejas para que no obliguen a repintar toda la pantalla."),
        const SizedBox(height: 10),
        _buildExampleCard(context, "Aislamiento de Pintado", const RepaintBoundaryDemo()),
        const SizedBox(height: 30),

        // --- 4. OPACITY VS ANIMATED OPACITY ---
        _buildSectionHeader(context, "4. Opacity Costoso vs Eficiente"),
        const Text("AnimatedOpacity es más eficiente que cambiar la opacidad en un build loop."),
        const SizedBox(height: 10),
        _buildExampleCard(context, "Transparencia Eficiente", const OpacityDemo()),
        const SizedBox(height: 50),
      ],
    );
  }
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
            // Widget que NO es const -> Se reconstruye en cada build del padre.
            _HeavyWidget.isNotConst(),
            // Widget que SÍ es const -> Flutter lo cachea y NO lo reconstruye.
            const _HeavyWidget.isConst(),
          ],
        )
      ],
    );
  }
}

// --- HELPERS ---

Widget _buildSectionHeader(BuildContext context, String title) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(thickness: 1),
      ],
    ),
  );
}

Widget _buildExampleCard(BuildContext context, String title, Widget content) {
  final theme = Theme.of(context);
  return Container(
    decoration: BoxDecoration(
      color: theme.cardColor,
      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(title, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
        ),
        Padding(padding: const EdgeInsets.all(15), child: content),
      ],
    ),
  );
}

/// Un widget de demostración para visualizar reconstrucciones.
class _HeavyWidget extends StatelessWidget {
  final Color color;
  final String text;

  /// Constructor CONSTANTE.
  /// Flutter puede cachear y reutilizar instancias de este widget.
  const _HeavyWidget.isConst({super.key})
      : color = Colors.grey,
        text = "SOY CONST\n(Estático)";

  /// Constructor NO constante.
  /// Genera un color aleatorio para demostrar que se crea una nueva instancia.
  _HeavyWidget.isNotConst({super.key})
      : color = Colors.primaries[Random().nextInt(Colors.primaries.length)],
        text = "NO CONST\n(Rebuild!)";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 100,
      color: color,
      alignment: Alignment.center,
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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