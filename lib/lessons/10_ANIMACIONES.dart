import 'dart:math';
import 'package:flutter/material.dart';

class Lab10Animaciones extends StatelessWidget {
  const Lab10Animaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 10: Animaciones",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // --- 1. Animaciones Implícitas ---
        _buildSectionHeader("1. Animaciones Implícitas"),
        const Text("Widgets que se animan automáticamente cuando sus propiedades cambian. Son los más fáciles de usar."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "AnimatedContainer y AnimatedOpacity",
          const ImplicitAnimationDemo(),
        ),

        const SizedBox(height: 30),

        // --- 2. Animaciones Explícitas ---
        _buildSectionHeader("2. Animaciones Explícitas"),
        const Text("Requieren un AnimationController para un control preciso sobre la duración, repetición y dirección de la animación."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "RotationTransition con AnimationController",
          const ExplicitAnimationDemo(),
        ),

        const SizedBox(height: 30),

        // --- 3. Hero Animations ---
        _buildSectionHeader("3. Animaciones de Héroe"),
        const Text("Crean una transición visual fluida de un widget entre dos pantallas. Ambos widgets deben estar envueltos en un `Hero` con el mismo `tag`."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Transición de Héroe",
          const HeroAnimationDemo(),
        ),

        const SizedBox(height: 30),

        // --- 4. Staggered Animations ---
        _buildSectionHeader("4. Animaciones Escalonadas"),
        const Text("Permiten orquestar múltiples animaciones para que se ejecuten en secuencia o con solapamiento, creando efectos complejos."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Lista con Fade-In Escalonado",
          const StaggeredListDemo(),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  // --- Widgets de estructura (reutilizados de otros laboratorios) ---

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              const Divider(thickness: 1),
            ],
          ),
        );
      }
    );
  }

  Widget _buildExampleCard(String title, Widget content) {
    return Builder(
      builder: (context) {
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
    );
  }
}

// ==========================================
// DEMOS INTERACTIVOS
// ==========================================

// --- 1. Implicit Animation Demo ---
class ImplicitAnimationDemo extends StatefulWidget {
  const ImplicitAnimationDemo({super.key});
  @override
  State<ImplicitAnimationDemo> createState() => _ImplicitAnimationDemoState();
}

class _ImplicitAnimationDemoState extends State<ImplicitAnimationDemo> {
  bool _isToggled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: _isToggled ? 200 : 100,
          height: 100,
          decoration: BoxDecoration(
            color: _isToggled ? theme.colorScheme.secondary : theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(_isToggled ? 8 : 24),
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _isToggled ? 1.0 : 0.5,
              child: Text(
                "Animar",
                style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _isToggled = !_isToggled),
          child: const Text("Alternar Animación"),
        ),
      ],
    );
  }
}

// --- 2. Explicit Animation Demo ---
class ExplicitAnimationDemo extends StatefulWidget {
  const ExplicitAnimationDemo({super.key});
  @override
  State<ExplicitAnimationDemo> createState() => _ExplicitAnimationDemoState();
}

class _ExplicitAnimationDemoState extends State<ExplicitAnimationDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // El 'TickerProvider'
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose(); // ¡Muy importante liberar el controller!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotationTransition(
          turns: _controller,
          child: Icon(Icons.sync, size: 80, color: Theme.of(context).colorScheme.tertiary),
        ),
        const SizedBox(height: 20),
        Text("Animación en bucle con repetición.", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// --- 3. Hero Animation Demo ---
class HeroAnimationDemo extends StatelessWidget {
  const HeroAnimationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const _HeroDetailPage(),
          ));
        },
        child: const Hero(
          tag: 'flutter-logo-hero',
          child: FlutterLogo(size: 80),
        ),
      ),
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Héroe")),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Hero(
            tag: 'flutter-logo-hero',
            child: FlutterLogo(size: 300),
          ),
        ),
      ),
    );
  }
}

// --- 4. Staggered List Animation ---
class StaggeredListDemo extends StatefulWidget {
  const StaggeredListDemo({super.key});
  @override
  State<StaggeredListDemo> createState() => _StaggeredListDemoState();
}

class _StaggeredListDemoState extends State<StaggeredListDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final int _itemCount = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: List.generate(_itemCount, (index) {
            // Calcula el intervalo para cada item
            final intervalStart = (index / _itemCount) * 0.5;
            final intervalEnd = intervalStart + 0.5;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Crea una animación de curva para este item específico
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    intervalStart,
                    min(intervalEnd, 1.0),
                    curve: Curves.easeOut,
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Item Animado ${index + 1}'),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Repetir Animación"),
          onPressed: () {
            _controller.reset();
            _controller.forward();
          },
        )
      ],
    );
  }
}