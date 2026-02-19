import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Shortcuts

class Lab25WebDesktop extends StatelessWidget {
  const Lab25WebDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 25: Web & Desktop", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. RESPONSIVE LAYOUT ---
        _buildSectionHeader("1. Adaptabilidad (Web/Desktop)"),
        const Text("Layout que cambia radicalmente según el espacio disponible."),
        const SizedBox(height: 10),
        _buildExampleCard("Layout Fluido", const ResponsiveLayoutDemo()),
        const SizedBox(height: 30),

        // --- 2. MOUSE INTERACTIONS ---
        _buildSectionHeader("2. Mouse Regions (Hover)"),
        const Text("Interacciones de ratón típicas de escritorio."),
        const SizedBox(height: 10),
        _buildExampleCard("Hover Effects & Cursor", const MouseRegionDemo()),
        const SizedBox(height: 30),

        // --- 3. SHORTCUTS ---
        _buildSectionHeader("3. Atajos de Teclado"),
        const Text("Uso de teclado físico (Shortcuts & Intent)."),
        const SizedBox(height: 10),
        _buildExampleCard("Prueba Ctrl+I (o Cmd+I)", const ShortcutsDemo()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. RESPONSIVE LAYOUT
class ResponsiveLayoutDemo extends StatelessWidget {
  const ResponsiveLayoutDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isWide = constraints.maxWidth > 500;
      return Container(
        height: 150,
        color: isWide ? Colors.purple.shade50 : Colors.blue.shade50,
        child: isWide 
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.desktop_windows), SizedBox(width: 10), Text("Modo ESCRITORIO (Horizontal)")])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.phone_android), SizedBox(height: 10), Text("Modo MÓVIL (Vertical)")]),
      );
    });
  }
}

// 2. MOUSE REGION
class MouseRegionDemo extends StatefulWidget {
  const MouseRegionDemo({super.key});
  @override
  State<MouseRegionDemo> createState() => _MouseRegionDemoState();
}
class _MouseRegionDemoState extends State<MouseRegionDemo> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // Cambia el cursor
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: _isHovering ? Colors.indigo : Colors.grey,
          borderRadius: BorderRadius.circular(_isHovering ? 20 : 8),
          boxShadow: _isHovering ? [const BoxShadow(color: Colors.indigoAccent, blurRadius: 10)] : [],
        ),
        child: Center(child: Text(_isHovering ? "¡HOVER DETECTADO!" : "Pasa el ratón por aquí", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

// 3. SHORTCUTS DEMO
class IncrementIntent extends Intent { const IncrementIntent(); }

class ShortcutsDemo extends StatefulWidget {
  const ShortcutsDemo({super.key});
  @override
  State<ShortcutsDemo> createState() => _ShortcutsDemoState();
}
class _ShortcutsDemoState extends State<ShortcutsDemo> {
  int _count = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Shortcuts requiere Foco
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        // Detectar teclas simples
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyI && HardwareKeyboard.instance.isControlPressed) {
          setState(() => _count++);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(), // Asegurar foco al tocar
        child: Container(
          height: 100,
          color: _focusNode.hasFocus ? Colors.green.shade50 : Colors.grey.shade100,
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_focusNode.hasFocus ? "Teclado Activo" : "Toca aquí para activar teclado", style: TextStyle(color: _focusNode.hasFocus ? Colors.green : Colors.grey)),
            const SizedBox(height: 5),
            const Text("Presiona 'Ctrl + I' para incrementar"),
            Text("Contador: $_count", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
          ]),
        ),
      ),
    );
  }
}
