# Animaciones en Flutter - Guía Completa

## 📚 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Conceptos Fundamentales](#conceptos-fundamentales)
3. [AnimationController](#animationcontroller)
4. [Tweens](#tweens)
5. [Implicit Animations](#implicit-animations)
6. [Explicit Animations](#explicit-animations)
7. [Custom Animations](#custom-animations)
8. [Hero Animations](#hero-animations)
9. [Page Transitions](#page-transitions)
10. [Lottie Animations](#lottie-animations)
11. [Physics-based Animations](#physics-based-animations)
12. [Ejemplos Prácticos](#ejemplos-prácticos)
13. [Performance](#performance)
14. [Mejores Prácticas](#mejores-prácticas)

---

## Introducción

Las animaciones en Flutter permiten crear experiencias fluidas y atractivas. Flutter proporciona dos enfoques:

### Tipos de Animaciones

| Tipo | Control | Complejidad | Caso de Uso |
|------|---------|------------|-----------|
| **Implicit** | Automático | Baja | Cambios simples (color, tamaño) |
| **Explicit** | Manual | Media | Animaciones complejas coordinadas |
| **Custom** | Completo | Alta | Animaciones personalizadas |
| **Physics** | Realista | Media | Comportamiento natural |

### Curvas de Animación

```dart
// Curvas predefinidas
Curves.linear             // Velocidad constante
Curves.easeIn             // Comienza lento
Curves.easeOut            // Termina lento
Curves.easeInOut          // Lento al inicio y final
Curves.bounceIn           // Rebote al inicio
Curves.bounceOut          // Rebote al final
Curves.elasticIn          // Efecto elástico al inicio
Curves.elasticOut         // Efecto elástico al final
Curves.fastOutSlowIn      // Material estándar
Curves.fastLinearToSlowCurveEaseIn // Complejo
```

---

## Conceptos Fundamentales

### TickerProvider

```dart
// TickerProvider proporciona "ticks" para animaciones
// Usar TickerProviderStateMixin para StatefulWidget

class MyAnimationScreen extends StatefulWidget {
  @override
  State<MyAnimationScreen> createState() => _MyAnimationScreenState();
}

class _MyAnimationScreenState extends State<MyAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this, // TickerProvider
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ...
  }
}

// Para StatelessWidget, usar SingleTickerProviderStateMixin
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  // Solo un AnimationController
}

// Para múltiples AnimationControllers
class MyComplexScreen extends StatefulWidget {
  @override
  State<MyComplexScreen> createState() => _MyComplexScreenState();
}

class _MyComplexScreenState extends State<MyComplexScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  // ...
}
```

### Animation Status

```dart
// Estados de la animación
void _setupAnimationListeners() {
  _controller.addStatusListener((status) {
    if (status == AnimationStatus.forward) {
      print('Iniciando animación adelante');
    } else if (status == AnimationStatus.completed) {
      print('Animación completada');
    } else if (status == AnimationStatus.reverse) {
      print('Revirtiendo animación');
    } else if (status == AnimationStatus.dismissed) {
      print('Animación descartada');
    }
  });
}

// Escuchar cambios de valor
void _setupValueListeners() {
  _controller.addListener(() {
    print('Valor actual: ${_controller.value}'); // 0.0 a 1.0
  });
}
```

---

## AnimationController

### Ciclo de vida

import 'dart:math';
```dart
class AnimationControllerExample extends StatefulWidget {
  @override
  State<AnimationControllerExample> createState() =>
      _AnimationControllerExampleState();
}

class _AnimationControllerExampleState extends State<AnimationControllerExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // Crear controller
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      reverseDuration: Duration(seconds: 1), // Duración al revertir
      vsync: this,
      value: 0.5, // Valor inicial
    );

    // Escuchar cambios
    _controller.addListener(() {
      setState(() {}); // Reconstruir widget
    });

    // Escuchar estado
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Completado, revertir
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimationController')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animación basada en valor del controller
            Transform.rotate(
              angle: _controller.value * 2 * pi, // 0 a 2π
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _controller.forward,
                  child: Text('Adelante'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _controller.reverse,
                  child: Text('Atrás'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _controller.stop,
                  child: Text('Detener'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _controller.repeat(); // Repetir infinitamente
                  },
                  child: Text('Repetir'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Valor: ${_controller.value.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

// Métodos útiles
_controller.forward();           // Comenzar desde inicio
_controller.forward(from: 0.5);  // Comenzar desde valor específico
_controller.reverse();            // Revertir
_controller.stop();               // Detener
_controller.repeat();             // Repetir infinitamente
_controller.repeat(reverse: true);// Repetir hacia adelante y atrás
_controller.fling(velocity: 2.0); // Animación con inercia
```

---

## Tweens

### Concepto Básico

import 'package:flutter/material.dart';
```dart
// Tween mapea valores de 0.0-1.0 a un rango específico

class TweenExample extends StatefulWidget {
  @override
  State<TweenExample> createState() => _TweenExampleState();
}

class _TweenExampleState extends State<TweenExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // DoubleTween
    _sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // ColorTween
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // OffsetTween
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(100, 100),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    return Scaffold(
      appBar: AppBar(title: Text('Tweens')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usar AnimatedBuilder para reconstruir solo los widgets necesarios
            AnimatedBuilder(
              animation: _sizeAnimation,
              builder: (context, child) {
                return Container(
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                  color: _colorAnimation.value,
                  child: child,
                );
              },
              child: Center(
                child: Text(
                  'Animado',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 32),
            AnimatedBuilder(
              animation: _offsetAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: _offsetAnimation.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Tweens Disponibles

```dart
// Diferentes tipos de Tweens
Tween<double>(begin: 0, end: 100)                    // Números
Tween<int>(begin: 0, end: 10)                        // Enteros
Tween<Color?>(begin: Colors.blue, end: Colors.red) // Colores
Tween<Offset>(begin: Offset(0,0), end: Offset(1,1))// Desplazamiento
Tween<Size>(begin: Size(0,0), end: Size(100,100))  // Tamaño
Tween<Rect>()                                       // Rectángulo
Tween<Matrix4>()                                    // Transformaciones 3D

// Tween personalizado
class CustomColorTween extends Tween<Color?> {
  CustomColorTween({Color? begin, Color? end})
      : super(begin: begin, end: end);

  @override
  Color? lerp(double t) {
    // Interpolación personalizada
    return Color.lerp(begin, end, t);
  }
}
```

---

## Implicit Animations

### AnimatedContainer

```dart
class AnimatedContainerExample extends StatefulWidget {
  @override
  State<AnimatedContainerExample> createState() =>
      _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool _isLarge = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedContainer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              width: _isLarge ? 300 : 100,
              height: _isLarge ? 300 : 100,
              color: _isLarge ? Colors.red : Colors.blue,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  _isLarge ? 50 : 10,
                ),
                boxShadow: [
                  if (_isLarge)
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                ],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLarge = !_isLarge);
              },
              child: Text('Toggle'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### AnimatedOpacity

```dart
class AnimatedOpacityExample extends StatefulWidget {
  @override
  State<AnimatedOpacityExample> createState() =>
      _AnimatedOpacityExampleState();
}

class _AnimatedOpacityExampleState extends State<AnimatedOpacityExample> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedOpacity')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: 500),
              child: Container(
                width: 150,
                height: 150,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _opacity = _opacity == 1.0 ? 0.0 : 1.0;
                });
              },
              child: Text('Fade'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### AnimatedPositioned

```dart
class AnimatedPositionedExample extends StatefulWidget {
  @override
  State<AnimatedPositionedExample> createState() =>
      _AnimatedPositionedExampleState();
}

class _AnimatedPositionedExampleState extends State<AnimatedPositionedExample> {
  bool _isRight = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedPositioned')),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            left: _isRight ? null : 0,
            right: _isRight ? 0 : null,
            top: 100,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _isRight = !_isRight);
              },
              child: Text('Mover'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### AnimatedCrossFade

```dart
class AnimatedCrossFadeExample extends StatefulWidget {
  @override
  State<AnimatedCrossFadeExample> createState() =>
      _AnimatedCrossFadeExampleState();
}

class _AnimatedCrossFadeExampleState extends State<AnimatedCrossFadeExample> {
  bool _showFirst = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedCrossFade')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedCrossFade(
              firstChild: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: Center(child: Text('Primero')),
              ),
              secondChild: Container(
                width: 200,
                height: 200,
                color: Colors.red,
                child: Center(child: Text('Segundo')),
              ),
              crossFadeState: _showFirst
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 500),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() => _showFirst = !_showFirst);
              },
              child: Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### AnimatedDefaultTextStyle

```dart
class AnimatedDefaultTextStyleExample extends StatefulWidget {
  @override
  State<AnimatedDefaultTextStyleExample> createState() =>
      _AnimatedDefaultTextStyleExampleState();
}

class _AnimatedDefaultTextStyleExampleState
    extends State<AnimatedDefaultTextStyleExample> {
  bool _isBig = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedDefaultTextStyle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              style: TextStyle(
                fontSize: _isBig ? 48 : 24,
                fontWeight: _isBig ? FontWeight.bold : FontWeight.normal,
                color: _isBig ? Colors.red : Colors.blue,
              ),
              duration: Duration(milliseconds: 500),
              child: Text('Tamaño Dinámico'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() => _isBig = !_isBig);
              },
              child: Text('Cambiar tamaño'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Explicit Animations

### AnimatedBuilder

import 'dart:math';
```dart
class AnimatedBuilderExample extends StatefulWidget {
  @override
  State<AnimatedBuilderExample> createState() =>
      _AnimatedBuilderExampleState();
}

class _AnimatedBuilderExampleState extends State<AnimatedBuilderExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedBuilder')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: Container(
                width: 100 + (sin(_controller.value * 2 * pi) * 50),
                height: 100 + (sin(_controller.value * 2 * pi) * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HSVColor.fromAHSV(
                    1.0,
                    (_controller.value * 360) % 360,
                    1.0,
                    1.0,
                  ).toColor(),
                ),
                child: child,
              ),
            );
          },
          child: Center(
            child: Text(
              'Girando',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Transition

```dart
class TransitionExample extends StatefulWidget {
  @override
  State<TransitionExample> createState() => _TransitionExampleState();
}

class _TransitionExampleState extends State<TransitionExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
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
    return Scaffold(
      appBar: AppBar(title: Text('Transitions')),
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Múltiples\nTransiciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
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

### Transitions Disponibles

```dart
// Fade
FadeTransition(opacity: animation, child: widget)

// Scale
ScaleTransition(scale: animation, child: widget)

// Slide
SlideTransition(position: animation, child: widget)

// Rotation
RotationTransition(turns: animation, child: widget)

// Size
SizeTransition(sizeFactor: animation, child: widget)

// Positioned
PositionedTransition(rect: animation, child: widget)

// Relative
RelativeRectTween(begin: rect1, end: rect2)

// Decorations
DecoratedBoxTransition(decoration: animation, child: widget)
```

---

## Custom Animations

### CustomPaint

import 'dart:math';
```dart
class CustomPaintExample extends StatefulWidget {
  @override
  State<CustomPaintExample> createState() => _CustomPaintExampleState();
}

class _CustomPaintExampleState extends State<CustomPaintExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CustomPaint')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: CircleAnimationPainter(_controller.value),
              size: Size(300, 300),
            );
          },
        ),
      ),
    );
  }
}

class CircleAnimationPainter extends CustomPainter {
  final double progress;

  CircleAnimationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 100 * (0.5 + progress * 0.5);

    // Dibujar círculo que crece y se desvanece
    canvas.drawCircle(center, radius, paint);

    // Dibujar varias capas
    paint.color = Colors.blue.withOpacity(1 - progress);
    for (int i = 0; i < 3; i++) {
      final layerRadius = radius - (i * 20);
      if (layerRadius > 0) {
        canvas.drawCircle(center, layerRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CircleAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

### Wave Animation

import 'dart:math';
```dart
class WaveAnimationPainter extends CustomPainter {
  final double progress;
  final Color waveColor;

  WaveAnimationPainter({
    required this.progress,
    this.waveColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = 60.0;

    // Punto inicial
    path.moveTo(0, size.height * 0.6);

    // Crear onda
    for (double x = 0; x <= size.width; x += waveLength / 4) {
      final y = size.height * 0.6 +
          sin((x + progress * waveLength) * 2 * pi / waveLength) *
              waveHeight;
      path.lineTo(x, y);
    }

    // Cerrar camino
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveAnimationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class WaveAnimationScreen extends StatefulWidget {
  @override
  State<WaveAnimationScreen> createState() => _WaveAnimationScreenState();
}

class _WaveAnimationScreenState extends State<WaveAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wave Animation')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WaveAnimationPainter(
                progress: _controller.value,
                waveColor: Colors.blue,
              ),
              size: Size(300, 200),
            );
          },
        ),
      ),
    );
  }
}
```

---

## Hero Animations

import 'package:flutter/material.dart';
import 'dart:math' as math;
```dart
class HeroAnimationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hero Animation')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Elemento $index'),
            trailing: Hero(
              tag: 'hero-$index',
              child: Container(
                width: 50,
                height: 50,                
                decoration: BoxDecoration(                  
                  color: Colors.primaries[index % Colors.primaries.length],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('$index'),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(heroTag: 'hero-$index'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String heroTag;

  const DetailScreen({required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle')),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(              
              color: Colors.primaries[int.parse(heroTag.split('-')[1]) % Colors.primaries.length],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Page Transitions

### Transiciones Personalizadas

```dart
class SlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  SlidePageRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    );
  }
}

// Usar
Navigator.push(
  context,
  SlidePageRoute(
    builder: (context) => NextScreen(),
  ),
);

// Fade Transition
class FadePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  FadePageRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// Scale Transition
class ScalePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  ScalePageRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      ),
      child: child,
    );
  }
}
```

---

## Lottie Animations

### Instalación y uso

```dart
// pubspec.yaml
dependencies:
  lottie: ^2.3.0

// Descargar archivos .json de https://lottie.host

import 'package:lottie/lottie.dart';

class LottieAnimationExample extends StatefulWidget {
  @override
  State<LottieAnimationExample> createState() =>
      _LottieAnimationExampleState();
}

class _LottieAnimationExampleState extends State<LottieAnimationExample>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lottie Animations')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Lottie desde archivo
            Lottie.asset(
              'assets/lottie/loading.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            SizedBox(height: 20),
            
            // Lottie desde URL
            Lottie.network(
              'https://lottie.host/xxxxx/xxxxx.json',
              width: 200,
              height: 200,
              repeat: false,
            ),
            SizedBox(height: 20),
            
            // Lottie con controller
            Lottie.asset(
              'assets/lottie/loading.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
              },
            ),
            SizedBox(height: 20),
            
            // Controles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _controller.forward,
                  child: Text('Play'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _controller.reverse,
                  child: Text('Reverse'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _controller.stop,
                  child: Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Lottie con eventos
class LottieEventsExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lottie Events')),
      body: Center(
        child: Lottie.asset(
          'assets/lottie/success.json',
          width: 300,
          height: 300,
          repeat: false,
          onLoaded: (composition) {
            print('Animation loaded');
          },
        ),
      ),
    );
  }
}
```

---

## Physics-based Animations

### Spring Animation

```dart
class SpringAnimationExample extends StatefulWidget {
  @override
  State<SpringAnimationExample> createState() =>
      _SpringAnimationExampleState();
}

class _SpringAnimationExampleState extends State<SpringAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spring Animation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _controller.forward(from: 0.0);
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Usar spring curve
                  final springAnimation = Tween<double>(begin: 1, end: 0.8)
                      .animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.elasticOut,
                        ),
                      );

                  return Transform.scale(
                    scale: springAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          'Tap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Fling Animation

```dart
class FlingAnimationExample extends StatefulWidget {
  @override
  State<FlingAnimationExample> createState() => _FlingAnimationExampleState();
}

class _FlingAnimationExampleState extends State<FlingAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: -double.infinity,
      upperBound: double.infinity,
    );
    _position = Offset.zero;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanEnd(DragEndDetails details) {
    // Velocidad de barrido
    _controller.fling(
      velocity: details.velocity.pixelsPerSecond.distance / 1000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fling Animation')),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position += details.delta;
            });
          },
          onPanEnd: _handlePanEnd,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            transform: Matrix4.translationValues(_position.dx, _position.dy, 0),
          ),
        ),
      ),
    );
  }
}
```

---

## Ejemplos Prácticos

### Loading Spinner

```dart
class LoadingSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const LoadingSpinner({
    this.size = 50,
    this.color = Colors.blue,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 4,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor:
                    AlwaysStoppedAnimation<Color>(widget.color),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Uso
LoadingSpinner(
  size: 60,
  color: Colors.blue,
)
```

### Pulse Animation

```dart
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Opacity(
        opacity: 0.7 + (_controller.value * 0.3),
        child: widget.child,
      ),
    );
  }
}

// Uso
PulseAnimation(
  child: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

### Shimmer Effect

```dart
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 - _controller.value * 2, 0),
              end: Alignment(1, 0),
              colors: [
                Colors.grey.withOpacity(0.3),
                Colors.grey.withOpacity(0.8),
                Colors.grey.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Uso
ShimmerEffect(
  child: Container(
    width: 200,
    height: 100,
    color: Colors.grey[300],
  ),
)
```

### Bounce Animation

```dart
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BounceAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
      ),
      child: widget.child,
    );
  }
}

// Uso
BounceAnimation(
  child: Icon(Icons.arrow_downward),
)
```

---

## Performance

### Optimizaciones

```dart
// ❌ Evitar - Reconstruye todo el widget
class BadPerformance extends StatefulWidget {
  @override
  State<BadPerformance> createState() => _BadPerformanceState();
}

class _BadPerformanceState extends State<BadPerformance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {}); // Reconstruye TODO
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Performance')),
      body: Center(
        child: Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Container(width: 100, height: 100, color: Colors.blue),
        ),
      ),
    );
  }
}

// ✅ Bien - Usa AnimatedBuilder
class GoodPerformance extends StatefulWidget {
  @override
  State<GoodPerformance> createState() => _GoodPerformanceState();
}

class _GoodPerformanceState extends State<GoodPerformance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Performance')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: child,
            );
          },
          child: Container(width: 100, height: 100, color: Colors.blue),
        ),
      ),
    );
  }
}

// RepaintBoundary para optimizar rendering
class OptimizedAnimation extends StatefulWidget {
  @override
  State<OptimizedAnimation> createState() => _OptimizedAnimationState();
}

class _OptimizedAnimationState extends State<OptimizedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Este widget NO se reconstruye
          Expanded(
            child: Container(color: Colors.grey[300]),
          ),
          // Solo esta parte se anima
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Mejores Prácticas

### 1. Usar ImplicitAnimation cuando sea posible

```dart
// ✅ Bien para cambios simples
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  width: _isLarge ? 200 : 100,
  color: _isLarge ? Colors.red : Colors.blue,
)

// ❌ Evitar complejidad innecesaria
AnimationController controller = ...
Animation animation = Tween(...).animate(...)
// Para solo cambiar tamaño y color
```

### 2. Siempre descartar AnimationControllers

```dart
// ✅ Bien
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ❌ Evitar - Memory leak
@override
void dispose() {
  super.dispose();
  // _controller nunca se libera
}
```

### 3. Usar Curves apropiadas

```dart
// ✅ Bien - Curva apropiada para contexto
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutQuad, // Natural para UI
  width: targetWidth,
)

// Para ingreso de usuario
curve: Curves.fastOutSlowIn

// Para notificaciones
curve: Curves.bounceOut

// Para descartes
curve: Curves.easeInBack
```

### 4. Optimizar rendering

```dart
// ✅ Bien - RepaintBoundary para animaciones complejas
RepaintBoundary(
  child: AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      // Rendering optimizado
      return ComplexWidget();
    },
  ),
)

// ✅ Bien - const widgets donde sea posible
AnimatedBuilder(
  animation: animation,
  builder: (context, child) {
    return Transform.rotate(
      angle: animation.value,
      child: child, // Reutiliza widget
    );
  },
  child: const MyWidget(), // const ahorra recursos
)
```

### 5. Usar duration apropiado

```dart
// Guía general
Duration.zero           // Instantáneo
Duration(ms: 150)       // Muy rápido (micro-interacciones)
Duration(ms: 300)       // Rápido (cambios de UI)
Duration(ms: 500)       // Normal (transiciones)
Duration(seconds: 1)    // Lento (animaciones complejas)
Duration(seconds: 2+)   // Muy lento (solo si es necesario)
```

### 6. Cancelar animaciones cuando sea necesario

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    _controller.stop(); // Pausar cuando app se va al fondo
  } else if (state == AppLifecycleState.resumed) {
    _controller.forward(); // Reanudar
  }
}
```

### 7. Testing de animaciones

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Animation works correctly', (tester) async {
    await tester.pumpWidget(MyAnimationApp());

    // Esperar animación inicial
    await tester.pumpAndSettle();

    // Encontrar widget animado
    expect(find.byType(Container), findsOneWidget);

    // Avanzar tiempo
    await tester.pump(Duration(milliseconds: 200));

    // Verificar cambios
    expect(/* verificación */, true);
  });
}
```

---

## Checklist de Animaciones

**Planificación:**
- ✅ Identificar tipo de animación (implicit/explicit/custom)
- ✅ Elegir duración apropiada
- ✅ Seleccionar curva que haga sentido
- ✅ Considerar performance

**Implementación:**
- ✅ Usar AnimatedBuilder o ImplicitAnimation
- ✅ Manejar AnimationController correctamente
- ✅ Siempre descartar controllers
- ✅ Optimizar con RepaintBoundary si es necesario

**Testing:**
- ✅ Probar animation flow
- ✅ Verificar disposición de recursos
- ✅ Testear transiciones

**Performance:**
- ✅ Evitar setState en animaciones
- ✅ Usar const widgets donde posible
- ✅ Monitorear frame rate (60 FPS objetivo)
- ✅ Perfilar con DevTools

---

Conceptos Relacionados:
- 02_STATEFUL_STATELESS_LIFECYCLE
- 03_ADVANCED_BUILDERS_STREAMS_FUTURE
- 18_WIDGETS_AVANZADOS
- 22_CLEAN_ARCHITECTURE
- EJERCICIOS_10_ANIMACIONES

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio/Avanzado**
