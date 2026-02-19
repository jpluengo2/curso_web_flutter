# Gestures y Eventos en Flutter: Guía Completa

## Introducción a Gestos y Eventos

Los gestos son interacciones del usuario con la pantalla: toques, deslizamientos, rotaciones, etc. Flutter proporciona widgets y APIs para manejar estos eventos de forma eficiente.

### Tipos de Gestos Comunes

- **Tap**: Toque simple
- **Double Tap**: Toque doble
- **Long Press**: Presión prolongada
- **Drag**: Arrastrar
- **Fling**: Movimiento rápido
- **Scale**: Pinch para ampliar/reducir
- **Rotation**: Girar con dos dedos

---

## 1. Tap (Toque Simple)

### 1.1 GestureDetector

import 'package:flutter/material.dart';
```dart
// Widget básico para detectar gestos
class TapExample extends StatefulWidget {
  const TapExample({Key? key}) : super(key: key);

  @override
  State<TapExample> createState() => _TapExampleState();
}

class _TapExampleState extends State<TapExample> {
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tap Example')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() => _tapCount++);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Taps: $_tapCount')),
            );
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Taps: $_tapCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 1.2 InkWell y Variantes

```dart
// InkWell - Efecto ripple (Material Design)
class InkWellExample extends StatelessWidget {
  const InkWellExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // InkWell básico
        InkWell(
          onTap: () => print('Tap 1'),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Text('Tap con efecto ripple'),
          ),
        ),

        // InkWell con color personalizado
        InkWell(
          onTap: () => print('Tap 2'),
          splashColor: Colors.orange,
          highlightColor: Colors.orangeAccent,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Text('Ripple naranja'),
          ),
        ),

        // Material con InkWell
        Material(
          child: InkWell(
            onTap: () => print('Tap 3'),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text('Material + InkWell'),
            ),
          ),
        ),

        // InkResponse (similar pero más control)
        InkResponse(
          onTap: () => print('Tap 4'),
          radius: 30,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Text('InkResponse'),
          ),
        ),
      ],
    );
  }
}
```

### 1.3 Diferenciar Tap vs Long Press

```dart
class TapVsLongPressExample extends StatefulWidget {
  const TapVsLongPressExample({Key? key}) : super(key: key);

  @override
  State<TapVsLongPressExample> createState() => _TapVsLongPressExampleState();
}

class _TapVsLongPressExampleState extends State<TapVsLongPressExample> {
  String _action = 'Toca o presiona largo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() => _action = 'Toque simple detectado');
          },
          onLongPress: () {
            setState(() => _action = 'Presión larga detectada');
          },
          onDoubleTap: () {
            setState(() => _action = 'Toque doble detectado');
          },
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _action,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 2. Drag (Arrastrar)

### 2.1 Arrastrar Elementos

```dart
class DragExample extends StatefulWidget {
  const DragExample({Key? key}) : super(key: key);

  @override
  State<DragExample> createState() => _DragExampleState();
}

class _DragExampleState extends State<DragExample> {
  Offset _position = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drag Example')),
      body: Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _position += details.delta;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Icon(Icons.drag_handle, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.2 Draggable y DragTarget

```dart
// Arrastra desde un widget a otro
class DraggableExample extends StatefulWidget {
  const DraggableExample({Key? key}) : super(key: key);

  @override
  State<DraggableExample> createState() => _DraggableExampleState();
}

class _DraggableExampleState extends State<DraggableExample> {
  List<String> _colors = ['Rojo', 'Azul', 'Verde', 'Amarillo'];
  List<String> _acceptedColors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Example')),
      body: Row(
        children: [
          // Origen: items arrastrables
          Expanded(
            child: Column(
              children: [
                const Text('Arrastra colores'),
                Expanded(
                  child: ListView.builder(
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      return Draggable<String>(
                        data: _colors[index],
                        feedback: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _colors[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_colors[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Destino: DragTarget
          Expanded(
            child: Column(
              children: [
                const Text('Suelta aquí'),
                Expanded(
                  child: DragTarget<String>(
                    onAccept: (data) {
                      setState(() {
                        _colors.remove(data);
                        _acceptedColors.add(data);
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty
                              ? Colors.green[100]
                              : Colors.grey[200],
                          border: Border.all(
                            color: candidateData.isNotEmpty
                                ? Colors.green
                                : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _acceptedColors.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_acceptedColors[index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.3 Detectar Fling (Movimiento Rápido)

```dart
class FlingExample extends StatefulWidget {
  const FlingExample({Key? key}) : super(key: key);

  @override
  State<FlingExample> createState() => _FlingExampleState();
}

class _FlingExampleState extends State<FlingExample> {
  String _direction = 'Espera un fling';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fling Example')),
      body: Center(
        child: GestureDetector(
          onPanEnd: (details) {
            // Calcular velocidad
            final velocity = details.velocity.pixelsPerSecond;
            final speed = velocity.distance;

            String direction = '';
            if (speed < 300) {
              direction = 'Movimiento lento';
            } else if (velocity.dx.abs() > velocity.dy.abs()) {
              // Horizontal
              direction = velocity.dx > 0 ? 'Fling DERECHA' : 'Fling IZQUIERDA';
            } else {
              // Vertical
              direction = velocity.dy > 0 ? 'Fling ABAJO' : 'Fling ARRIBA';
            }

            setState(() => _direction = direction);
          },
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _direction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 3. Scale (Zoom con Pinch)

### 3.1 Detectar Pinch Zoom

```dart
class PinchZoomExample extends StatefulWidget {
  const PinchZoomExample({Key? key}) : super(key: key);

  @override
  State<PinchZoomExample> createState() => _PinchZoomExampleState();
}

class _PinchZoomExampleState extends State<PinchZoomExample> {
  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinch Zoom Example')),
      body: Center(
        child: GestureDetector(
          onScaleStart: (details) {
            _baseScale = _scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = _baseScale * details.scale;
              // Limitar zoom
              if (_scale < 0.5) _scale = 0.5;
              if (_scale > 3.0) _scale = 3.0;
            });
          },
          child: Transform.scale(
            scale: _scale,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Scale: ${_scale.toStringAsFixed(2)}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3.2 InteractiveViewer (Imagen Zoomeable)

```dart
class InteractiveImageViewer extends StatelessWidget {
  const InteractiveImageViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Image Viewer')),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          'https://via.placeholder.com/500x500',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
```

---

## 4. Rotation (Rotación)

### 4.1 Detectar Rotación

import 'package:flutter/material.dart';
```dart
class RotationExample extends StatefulWidget {
  const RotationExample({Key? key}) : super(key: key);

  @override
  State<RotationExample> createState() => _RotationExampleState();
}

class _RotationExampleState extends State<RotationExample> {
  double _rotation = 0.0;
  double _baseRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotation Example')),
      body: Center(
        child: GestureDetector(          
          onScaleStart: (details) {
            _baseRotation = _rotation; // Guarda la rotación inicial
          },
          onScaleUpdate: (details) {
            setState(() {
              // Actualiza la rotación sumando el cambio del gesto
              _rotation = _baseRotation + details.rotation;
            });
          },
          child: Transform.rotate(
            angle: _rotation,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.rotate_right, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 5. GestureDetector Avanzado

### 5.1 Todas las Opciones

```dart
class AdvancedGestureDetectorExample extends StatefulWidget {
  const AdvancedGestureDetectorExample({Key? key}) : super(key: key);

  @override
  State<AdvancedGestureDetectorExample> createState() =>
      _AdvancedGestureDetectorExampleState();
}

class _AdvancedGestureDetectorExampleState
    extends State<AdvancedGestureDetectorExample> {
  String _lastGesture = 'Ninguno';
  String _details = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Gestures')),
      body: Center(
        child: GestureDetector(
          // Tap
          onTap: () => _updateGesture('Tap'),
          onDoubleTap: () => _updateGesture('Double Tap'),
          onTapDown: (details) =>
              _updateGesture('Tap Down', details.localPosition.toString()),
          onTapUp: (details) =>
              _updateGesture('Tap Up', details.localPosition.toString()),
          onTapCancel: () => _updateGesture('Tap Cancelled'),

          // Long Press
          onLongPress: () => _updateGesture('Long Press'),
          onLongPressStart: (details) =>
              _updateGesture('Long Press Start', details.localPosition.toString()),
          onLongPressMoveUpdate: (details) =>
              _updateGesture('Long Press Moving', details.localPosition.toString()),
          onLongPressUp: () => _updateGesture('Long Press Up'),
          onLongPressEnd: (details) =>
              _updateGesture('Long Press End', details.localPosition.toString()),

          // Drag
          onPanStart: (details) =>
              _updateGesture('Drag Start', details.globalPosition.toString()),
          onPanUpdate: (details) =>
              _updateGesture('Dragging', '${details.delta}'),
          onPanEnd: (details) =>
              _updateGesture('Drag End', '${details.velocity.pixelsPerSecond}'),
          onPanCancel: () => _updateGesture('Drag Cancelled'),

          // Scale
          onScaleStart: (details) => _updateGesture('Scale Start'),
          onScaleUpdate: (details) =>
              _updateGesture('Scaling', 'scale: ${details.scale}'),
          onScaleEnd: (details) => _updateGesture('Scale End'),

          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _lastGesture,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _details,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateGesture(String gesture, [String? detail]) {
    setState(() {
      _lastGesture = gesture;
      _details = detail ?? '';
    });
  }
}
```

---

## 6. Eventos de Teclado

### 6.1 Detectar Teclas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
```dart
class KeyboardEventExample extends StatefulWidget {
  const KeyboardEventExample({Key? key}) : super(key: key);

  @override
  State<KeyboardEventExample> createState() => _KeyboardEventExampleState();
}

class _KeyboardEventExampleState extends State<KeyboardEventExample> {
  late FocusNode _focusNode;
  String _keyPressed = 'Ninguna';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Events')),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            setState(() => _keyPressed = 'Flecha ARRIBA');
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            setState(() => _keyPressed = 'Flecha ABAJO');
          } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            setState(() => _keyPressed = 'ENTER');
          } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
            setState(() => _keyPressed = 'ESPACIO');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Presiona una tecla'),
              const SizedBox(height: 24),
              Text(
                _keyPressed,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 6.2 TextField con Eventos

```dart
class TextFieldWithKeyboardEvents extends StatefulWidget {
  const TextFieldWithKeyboardEvents({Key? key}) : super(key: key);

  @override
  State<TextFieldWithKeyboardEvents> createState() =>
      _TextFieldWithKeyboardEventsState();
}

class _TextFieldWithKeyboardEventsState
    extends State<TextFieldWithKeyboardEvents> {
  late TextEditingController _controller;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TextField Events')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() => _status = 'Escribiendo: $value');
              },
              onSubmitted: (value) {
                setState(() => _status = 'Enviado: $value');
              },
              onTap: () {
                setState(() => _status = 'Campo enfocado');
              },
              decoration: InputDecoration(
                labelText: 'Escribe algo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Listeners y Notificadores

### 7.1 GestureNotifier

import 'package:flutter/material.dart';
```dart
class CustomGestureNotifier extends ChangeNotifier {
  String _lastGesture = 'Ninguno';

  String get lastGesture => _lastGesture;

  void recordGesture(String gesture) {
    _lastGesture = gesture;
    notifyListeners();
  }
}

class GestureNotifierExample extends StatelessWidget {
  final _gestureNotifier = CustomGestureNotifier();

  GestureNotifierExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture Notifier')),
      body: Center(
        child: GestureDetector(
          onTap: () => _gestureNotifier.recordGesture('Tap'),
          onLongPress: () => _gestureNotifier.recordGesture('Long Press'),
          onPanUpdate: (details) =>
              _gestureNotifier.recordGesture('Dragging'),
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListenableBuilder(
              listenable: _gestureNotifier,
              builder: (context, child) {
                return Center(
                  child: Text(
                    _gestureNotifier.lastGesture,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Swipe (Deslizar)

### 8.1 Detectar Swipe

import 'package:flutter/material.dart';
```dart
class SwipeExample extends StatefulWidget {
  const SwipeExample({Key? key}) : super(key: key);

  @override
  State<SwipeExample> createState() => _SwipeExampleState();
}

class _SwipeExampleState extends State<SwipeExample> {
  int _imageIndex = 0;
  final List<String> _images = [
    'https://via.placeholder.com/500x500?text=Imagen+1',
    'https://via.placeholder.com/500x500?text=Imagen+2',
    'https://via.placeholder.com/500x500?text=Imagen+3',
    'https://via.placeholder.com/500x500?text=Imagen+4',
  ];

  void _handleSwipe(DragEndDetails details) {
    const int minFlingVelocity = 400;

    if (details.velocity.pixelsPerSecond.dx > minFlingVelocity) {
      // Swipe a la derecha - imagen anterior
      setState(() {
        _imageIndex =
            (_imageIndex - 1 + _images.length) % _images.length;
      });
    } else if (details.velocity.pixelsPerSecond.dx < -minFlingVelocity) {
      // Swipe a la izquierda - siguiente imagen
      setState(() {
        _imageIndex = (_imageIndex + 1) % _images.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Example')),
      body: Center(
        child: GestureDetector(
          onPanEnd: _handleSwipe,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                _images[_imageIndex],
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 24),
              Text(
                'Imagen ${_imageIndex + 1} de ${_images.length}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Desliza para cambiar imagen',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 9. Hit Testing y Absorb Pointer

### 9.1 Controlar Eventos

import 'package:flutter/material.dart';
```dart
class HitTestingExample extends StatefulWidget {
  const HitTestingExample({Key? key}) : super(key: key);

  @override
  State<HitTestingExample> createState() => _HitTestingExampleState();
}

class _HitTestingExampleState extends State<HitTestingExample> {
  bool _absorbPointer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hit Testing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AbsorbPointer - Bloquea eventos
            AbsorbPointer(
              absorbing: _absorbPointer,
              child: GestureDetector(
                onTap: () => print('Widget 1 tapped'),
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _absorbPointer ? Colors.grey : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _absorbPointer ? 'Bloqueado' : 'Tap aquí',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // IgnorePointer - Similar pero visual
            IgnorePointer(
              ignoring: _absorbPointer,
              child: Opacity(
                opacity: _absorbPointer ? 0.5 : 1.0,
                child: GestureDetector(
                  onTap: () => print('Widget 2 tapped'),
                  child: Container(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Tap aquí',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() => _absorbPointer = !_absorbPointer);
              },
              child: Text(_absorbPointer ? 'Desbloquear' : 'Bloquear'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 10. Best Practices

✅ **DO's:**
- Usar GestureDetector para gestos personalizados
- Usar InkWell para Material Design
- Proporcionar feedback visual
- Manejar casos límite
- Implementar accesibilidad

❌ **DON'Ts:**
- Anidar múltiples GestureDetector sin razón
- Ignorar la accesibilidad
- Bloquear eventos innecesariamente
- Hacer gestos demasiado sensibles
- Olvidar limpiar recursos

---

## 11. Ejercicios

### Ejercicio 1: Galería de Imágenes
Crear app con:
- Swipe para cambiar imagen
- Pinch para zoom
- Double tap para expandir

### Ejercicio 2: Juego Simple
Crear juego con:
- Tap para puntuar
- Drag para mover
- Fling para lanzar

### Ejercicio 3: Editor de Notas
Crear con:
- Long press para editar
- Swipe para eliminar
- Pinch para zoom texto

---

Conceptos Relacionados:
- 02_STATEFUL_STATELESS_LIFECYCLE
- 06_SCAFFOLD_NAVEGACION
- 07_FORMULARIOS
- 10_ANIMACIONES
- EJERCICIOS_11_GESTURES_EVENTOS

## Resumen

Los gestos son fundamentales para diversos tipos de aplicaciones.
- ✅ Interactividad
- ✅ Buena UX
- ✅ Navegación intuitiva
- ✅ Juegos
- ✅ Aplicaciones dinámicas

Flutter proporciona herramientas potentes para manejar cualquier tipo de gesto.
