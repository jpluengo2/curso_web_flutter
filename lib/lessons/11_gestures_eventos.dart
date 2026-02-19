import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Lab11Gestures extends StatelessWidget {
  const Lab11Gestures({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 11: Gestos y Eventos",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. TAPS BÁSICOS ---
        _buildSectionHeader("1. Detectores de Toques (Taps)"),
        const Text("Diferencia entre GestureDetector (lógico) e InkWell (visual)."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Tipos de Toque",
          const TapTypesDemo(),
        ),

        const SizedBox(height: 30),

        // --- 2. DRAG & DROP ---
        _buildSectionHeader("2. Arrastrar y Soltar (Drag & Drop)"),
        const Text("Juego: Arrastra el círculo de color a su caja correspondiente."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Juego de Colores",
          const DragDropGame(),
        ),

        const SizedBox(height: 30),

        // --- 3. SWIPE & FLING ---
        _buildSectionHeader("3. Deslizar (Swipe/Fling)"),
        const Text("Detecta la velocidad y dirección del deslizamiento."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Galería con Swipe",
          const SwipeGalleryDemo(),
        ),

        const SizedBox(height: 30),

        // --- 4. SCALE & ZOOM ---
        _buildSectionHeader("4. Zoom e Interacción (Scale)"),
        const Text("Usa dos dedos (o Ctrl + Rueda en web) para hacer zoom."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "InteractiveViewer (Pan/Zoom)",
          const InteractiveViewerDemo(),
        ),

        const SizedBox(height: 30),

        // --- 5. TECLADO ---
        _buildSectionHeader("5. Eventos de Teclado"),
        const Text("Toca el área gris para darle foco y luego presiona teclas."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Detector de Teclas",
          const KeyboardListenerDemo(),
        ),

        const SizedBox(height: 30),

        // --- 6. HIT TESTING ---
        _buildSectionHeader("6. Bloqueo de Eventos"),
        const Text("AbsorbPointer impide que los toques lleguen a los hijos."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "AbsorbPointer vs IgnorePointer",
          const HitTestDemo(),
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

// 1. TAP TYPES DEMO
class TapTypesDemo extends StatefulWidget {
  const TapTypesDemo({super.key});
  @override
  State<TapTypesDemo> createState() => _TapTypesDemoState();
}

class _TapTypesDemoState extends State<TapTypesDemo> {
  String _status = "Toca un botón";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          alignment: WrapAlignment.center,
          children: [
            // GestureDetector
            GestureDetector(
              onTap: () => setState(() => _status = "GestureDetector: Tap Simple"),
              onDoubleTap: () => setState(() => _status = "GestureDetector: Doble Tap!"),
              onLongPress: () => setState(() => _status = "GestureDetector: Presión Larga"),
              child: Container(
                width: 100, height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                child: const Text("Gesture", style: TextStyle(color: Colors.white)),
              ),
            ),
            // InkWell (Requiere Material ancestro)
            Material(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _status = "InkWell: Efecto Ripple"),
                splashColor: Colors.white.withOpacity(0.3),
                child: const SizedBox(
                  width: 100, height: 60,
                  child: Center(child: Text("InkWell", style: TextStyle(color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 2. DRAG & DROP GAME
class DragDropGame extends StatefulWidget {
  const DragDropGame({super.key});
  @override
  State<DragDropGame> createState() => _DragDropGameState();
}

class _DragDropGameState extends State<DragDropGame> {
  Color _targetColor = Colors.grey.shade200;
  String _message = "Arrastra aquí";
  final List<Color> _draggables = [Colors.red, Colors.green, Colors.blue];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zona de Destino (Drop Zone)
        DragTarget<Color>(
          onWillAccept: (color) => true, // Aceptamos cualquier color
          onAccept: (color) {
            setState(() {
              _targetColor = color;
              _message = "¡Color Aceptado!";
            });
          },
          onLeave: (_) => setState(() => _message = "¡No te vayas!"),
          builder: (context, candidates, rejects) {
            return Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: candidates.isNotEmpty ? candidates.first!.withOpacity(0.5) : _targetColor,
                border: Border.all(color: candidates.isNotEmpty ? Colors.black : Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.save_alt, 
                  color: _targetColor == Colors.grey.shade200 ? Colors.grey : Colors.white,
                  size: 40
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(_message),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        // Elementos Arrastrables
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _draggables.map((color) {
            return Draggable<Color>(
              data: color,
              // Widget mientras se arrastra (debajo del dedo)
              feedback: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle),
                child: const Icon(Icons.drag_handle, color: Colors.white),
              ),
              // Widget que queda en el sitio original mientras arrastras (fantasma)
              childWhenDragging: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
              ),
              // Widget normal en reposo
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// 3. SWIPE GALLERY DEMO
class SwipeGalleryDemo extends StatefulWidget {
  const SwipeGalleryDemo({super.key});
  @override
  State<SwipeGalleryDemo> createState() => _SwipeGalleryDemoState();
}

class _SwipeGalleryDemoState extends State<SwipeGalleryDemo> {
  int _index = 0;
  final List<Color> _pages = [Colors.teal, Colors.indigo, Colors.deepOrange];
  final List<String> _texts = ["Página 1", "Página 2", "Página 3"];

  void _handleSwipe(DragEndDetails details) {
    // Si la velocidad horizontal es mayor que la vertical, es un swipe horizontal
    if (details.primaryVelocity! < 0) {
      // Swipe Izquierda (Siguiente)
      setState(() => _index = (_index + 1) % _pages.length);
    } else if (details.primaryVelocity! > 0) {
      // Swipe Derecha (Anterior)
      setState(() => _index = (_index - 1 + _pages.length) % _pages.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 150,
        decoration: BoxDecoration(
          color: _pages[_index],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_texts[_index], style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.chevron_left, color: Colors.white54, size: 40),
                Text("Desliza", style: TextStyle(color: Colors.white54)),
                Icon(Icons.chevron_right, color: Colors.white54, size: 40),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// 4. INTERACTIVE VIEWER (ZOOM)
class InteractiveViewerDemo extends StatelessWidget {
  const InteractiveViewerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey.shade900,
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
            ),
            child: const Center(
              child: Text(
                "¡Haz Zoom!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 5. KEYBOARD LISTENER
class KeyboardListenerDemo extends StatefulWidget {
  const KeyboardListenerDemo({super.key});
  @override
  State<KeyboardListenerDemo> createState() => _KeyboardListenerDemoState();
}

class _KeyboardListenerDemoState extends State<KeyboardListenerDemo> {
  final FocusNode _focusNode = FocusNode();
  String _keyPressed = "Ninguna";
  bool _hasFocus = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
        setState(() => _hasFocus = true);
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            setState(() {
              _keyPressed = event.logicalKey.keyLabel;
            });
          }
        },
        child: Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hasFocus ? Colors.blue.shade50 : Colors.grey.shade200,
            border: Border.all(color: _hasFocus ? Colors.blue : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_hasFocus ? "Escuchando teclado..." : "Toca aquí para activar"),
              const SizedBox(height: 10),
              Text(
                "Tecla: $_keyPressed",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _hasFocus ? Colors.blue : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 6. HIT TEST DEMO
class HitTestDemo extends StatefulWidget {
  const HitTestDemo({super.key});
  @override
  State<HitTestDemo> createState() => _HitTestDemoState();
}

class _HitTestDemoState extends State<HitTestDemo> {
  bool _absorbing = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Bloquear Botón"),
          value: _absorbing,
          onChanged: (v) => setState(() => _absorbing = v),
        ),
        const SizedBox(height: 10),
        AbsorbPointer(
          absorbing: _absorbing,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Botón presionado!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _absorbing ? Colors.grey : Colors.blue,
            ),
            child: Text(_absorbing ? "Bloqueado (No Click)" : "¡Click Me!"),
          ),
        ),
      ],
    );
  }
}