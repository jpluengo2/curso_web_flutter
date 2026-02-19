# Performance Optimization en Flutter: Guía Completa

## Introducción a Performance

La optimización de performance es crucial para:
- **Experiencia fluida**: 60 FPS en la mayoría de dispositivos, 120 FPS en dispositivos de gama alta
- **Batería**: Consumo eficiente de recursos
- **Memoria**: No saturar la RAM
- **Startup rápido**: Tiempo de carga reducido
- **Satisfacción del usuario**: App responsiva

### Metas de Performance

- **Frame time**: < 16ms para 60 FPS
- **Startup**: < 5 segundos
- **Memory**: Uso razonable de RAM
- **Battery**: Mínimo consumo energético

---

## 1. Análisis de Performance

### 1.1 DevTools y Performance Monitor

```dart
// En main.dart
void main() {
  // Habilitar performance overlay
  // Presiona P en emulador/device
  debugPrintBeginFrameBanner = true;
  debugPrintEndFrameBanner = true;
  
  runApp(const MyApp());
}
```

**DevTools Performance Tab:**
- Frame rendering time
- Memory usage
- CPU usage
- Timeline

### 1.2 Profiling en Código

```dart
import 'dart:developer' as developer;

void measurePerformance(String label, VoidCallback operation) {
  final stopwatch = Stopwatch()..start();
  
  operation();
  
  stopwatch.stop();
  developer.Timeline.finishSync();
  
  print('$label took ${stopwatch.elapsedMilliseconds}ms');
}

// Uso
measurePerformance('Data fetch', () {
  fetchData();
});

// O con async
Future<void> measureAsync(String label, Future Function() operation) async {
  final stopwatch = Stopwatch()..start();
  
  await operation();
  
  stopwatch.stop();
  print('$label took ${stopwatch.elapsedMilliseconds}ms');
}

// Uso
await measureAsync('API call', () => api.fetchUsers());
```

---

## 2. Widget Performance

### 2.1 const Constructors

```dart
// ❌ Malo - Reconstruye en cada build
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.home),  // Se reconstruye siempre
        Text('Home'),      // Se reconstruye siempre
      ],
    );
  }
}

// ✅ Bueno - Usa const
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.home),  // Se reutiliza
        const Text('Home'),      // Se reutiliza
      ],
    );
  }
}

// ✅ Aún mejor - const en class
class _ConstantWidget extends StatelessWidget {
  const _ConstantWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.home),
        Text('Home'),
      ],
    );
  }
}
```

### 2.2 RepaintBoundary

```dart
// Aislar repaint a una parte específica
class OptimizedWidget extends StatefulWidget {
  const OptimizedWidget({Key? key}) : super(key: key);

  @override
  State<OptimizedWidget> createState() => _OptimizedWidgetState();
}

class _OptimizedWidgetState extends State<OptimizedWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Esta parte no se repinta cuando _counter cambia
        RepaintBoundary(
          child: Container(
            width: 300,
            height: 300,
            color: Colors.blue,
            child: const Icon(Icons.landscape, size: 100, color: Colors.white),
          ),
        ),
        
        // Esta parte SÍ se repinta
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: Text('Contador: $_counter'),
        ),
      ],
    );
  }
}
```

### 2.3 Evitar Build Recursivos

```dart
// ❌ Malo - Reconstruye demasiado
class BadList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        // Se reconstruye TODO al hacer scroll
        return Container(
          color: Colors.primaries[index % Colors.primaries.length],
          child: ListTile(
            title: Text('Item $index'),
            // Lógica compleja aquí
          ),
        );
      },
    );
  }
}

// ✅ Bueno - Componente separado
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: (context, index) {
        return _ListItem(index: index);
      },
    );
  }
}

class _ListItem extends StatelessWidget {
  final int index;

  const _ListItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: ListTile(
        title: Text('Item $index'),
      ),
    );
  }
}
```

---

## 3. Optimización de Listas

### 3.1 ListView.builder vs ListView

```dart
// ❌ Malo - Carga todo en memoria
class BadLargeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(
        10000,
        (index) => ListTile(title: Text('Item $index')),
      ),
    );
  }
}

// ✅ Bueno - Solo renderiza visible
class OptimizedLargeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10000,
      itemBuilder: (context, index) {
        return ListTile(title: Text('Item $index'));
      },
    );
  }
}

// ✅ Aún mejor - Con separador
class ListWithSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10000,
      itemBuilder: (context, index) {
        return ListTile(title: Text('Item $index'));
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }
}
```

### 3.2 Lazy Loading

```dart
class LazyLoadingList extends StatefulWidget {
  const LazyLoadingList({Key? key}) : super(key: key);

  @override
  State<LazyLoadingList> createState() => _LazyLoadingListState();
}

class _LazyLoadingListState extends State<LazyLoadingList> {
  final List<int> _items = [];
  bool _isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMoreItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Si estamos cerca del final, cargar más
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading) {
        _loadMoreItems();
      }
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoading = true);

    // Simular carga
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _items.addAll(
        List.generate(20, (index) => _items.length + index),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lazy Loading')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListTile(
            title: Text('Item ${_items[index]}'),
          );
        },
      ),
    );
  }
}
```

---

## 4. Image Caching y Optimization

### 4.1 CachedNetworkImage

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedImageWidget extends StatelessWidget {
  const OptimizedImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: 'https://via.placeholder.com/300x300',
      placeholder: (context, url) => const Shimmer(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fadeInDuration: const Duration(milliseconds: 300),
      cacheManager: CacheManager(),
    );
  }
}
```

### 4.2 Image Resize

```dart
// ❌ Malo - Descarga imagen completa
Image.network('https://example.com/image.jpg');

// ✅ Bueno - Redimensiona
Image.network(
  'https://example.com/image.jpg?w=300&h=300',
  width: 300,
  height: 300,
  fit: BoxFit.cover,
)
```

### 4.3 Precache Imágenes

```dart
class ImagePrecacheExample extends StatefulWidget {
  const ImagePrecacheExample({Key? key}) : super(key: key);

  @override
  State<ImagePrecacheExample> createState() => _ImagePrecacheExampleState();
}

class _ImagePrecacheExampleState extends State<ImagePrecacheExample> {
  @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  Future<void> _precacheImages() async {
    final urls = [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
      'https://example.com/image3.jpg',
    ];

    for (final url in urls) {
      await precacheImage(NetworkImage(url), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Precache')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Image.network(
            'https://via.placeholder.com/300x300?text=Image${index + 1}',
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
```

---

## 5. Memory Management

### 5.1 Liberar Recursos

```dart
class ResourceManagement extends State<MyWidget> {
  late StreamSubscription _subscription;
  late Timer _timer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // Inicializar
    _subscription = myStream.listen((data) {});
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {});
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // ✅ CRÍTICO - Liberar recursos
    _subscription.cancel();
    _timer.cancel();
    _controller.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### 5.2 Memory Leaks Prevention

```dart
// ❌ Malo - Memory leak
class BadListener extends StatefulWidget {
  @override
  State<BadListener> createState() => _BadListenerState();
}

class _BadListenerState extends State<BadListener> {
  @override
  void initState() {
    super.initState();
    // No se cancela - memory leak
    myStream.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}

// ✅ Bueno - Sin memory leak
class GoodListener extends StatefulWidget {
  @override
  State<GoodListener> createState() => _GoodListenerState();
}

class _GoodListenerState extends State<GoodListener> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = myStream.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}
```

### 5.3 Detectar Memory Leaks

```dart
void checkMemory() {
  // Usar DevTools Memory tab:
  // 1. Tomar snapshot de memoria
  // 2. Hacer acciones
  // 3. Tomar nuevo snapshot
  // 4. Comparar diferencias
  
  // O usar vm_service
}
```

---

## 6. Compilación y Build Optimization

### 6.1 Release Build

```bash
# Compilar para release (optimizado)
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release --csp

# Medir tamaño
flutter build apk --analyze-size
```

### 6.2 Reducir Tamaño

```yaml
# pubspec.yaml
# Usar dependencias ligeras
dependencies:
  # Bien - ligera
  http: ^1.1.0
  
  # Evitar - pesada
  # dio: (si solo necesitas http)

# Usar plugin selection
flutter pub get --no-precompile
```

### 6.3 Obfuscation (Android/iOS)

```bash
# Android
flutter build apk --obfuscate --split-debug-info=./debug_info

# iOS
flutter build ios --obfuscate --split-debug-info=./debug_info
```

---

## 7. Network Optimization

### 7.1 Connection Management

```dart
class OptimizedNetworkService {
  late HttpClient _httpClient;

  OptimizedNetworkService() {
    _httpClient = HttpClient()
      ..connectionTimeout = Duration(seconds: 30)
      ..badCertificateCallback = (_, __, ___) => false;
  }

  Future<T> fetchWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        
        await Future.delayed(retryDelay * attempt);
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  void dispose() {
    _httpClient.close();
  }
}
```

### 7.2 Data Compression

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Comprimir JSON
String compressJson(Map<String, dynamic> data) {
  final json = jsonEncode(data);
  final bytes = utf8.encode(json);
  // Comprimir con gzip
  return base64Encode(gzip.encode(bytes));
}

// Descomprimir
Map<String, dynamic> decompressJson(String compressed) {
  final bytes = base64Decode(compressed);
  // Descomprimir
  final json = utf8.decode(gzip.decode(bytes));
  return jsonDecode(json);
}
```

---

## 8. Battery Optimization

### 8.1 Reducir Cálculos

```dart
// ❌ Malo - Cálculos en build
class BadPerformance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Esto se ejecuta cada frame
    final complexCalculation = expensiveComputation();
    
    return Text(complexCalculation);
  }
}

// ✅ Bueno - Cache el resultado
class GoodPerformance extends StatefulWidget {
  @override
  State<GoodPerformance> createState() => _GoodPerformanceState();
}

class _GoodPerformanceState extends State<GoodPerformance> {
  late String _cachedResult;

  @override
  void initState() {
    super.initState();
    _cachedResult = expensiveComputation();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_cachedResult);
  }
}
```

### 8.2 Reducir Animaciones

```dart
// ❌ Animación continua
class BadAnimation extends StatefulWidget {
  @override
  State<BadAnimation> createState() => _BadAnimationState();
}

class _BadAnimationState extends State<BadAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(); // ❌ Continúa siempre
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _controller, child: Container());
  }
}

// ✅ Animación controlada
class GoodAnimation extends StatefulWidget {
  @override
  State<GoodAnimation> createState() => _GoodAnimationState();
}

class _GoodAnimationState extends State<GoodAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startAnimation,
      child: ScaleTransition(scale: _controller, child: Container()),
    );
  }
}
```

---

## 9. Monitoreo y Profiling

### 9.1 Performance Monitoring

```dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitoring {
  final _performance = FirebasePerformance.instance;

  Future<void> measureCustomTrace(String traceName, Future Function() operation) async {
    final trace = _performance.newTrace(traceName);
    
    try {
      await trace.start();
      await operation();
    } finally {
      await trace.stop();
    }
  }

  Future<void> measureHttpTrace(String url, Future Function() operation) async {
    final httpMetric = _performance.newHttpMetric(url, HttpMethod.Get);
    
    try {
      await httpMetric.start();
      await operation();
      httpMetric.httpResponseCode = 200;
    } finally {
      await httpMetric.stop();
    }
  }
}
```

### 9.2 Custom Metrics

```dart
class CustomMetrics {
  static void recordUserAction(String actionName, {Map<String, String>? attributes}) {
    // Registrar acción del usuario
    // Enviar a analytics
  }

  static void recordTiming(String event, Duration duration) {
    // Registrar tiempo de evento
  }

  static void recordMemoryUsage() {
    // Registrar uso de memoria
  }
}
```

---

## 10. Best Practices

✅ **DO's:**
- Usar const constructors
- Implementar lazy loading
- Cachear datos y imágenes
- Liberar recursos en dispose
- Monitorear performance
- Usar RepaintBoundary
- Profiles regularmente

❌ **DON'Ts:**
- Hacer cálculos complejos en build
- Cargar listas completas de una vez
- Crear animaciones infinitas
- Olvidar dispose
- Anidar layouts complejos
- Descargar imágenes sin redimensionar

---

## 11. Checklist de Performance

- ✅ Startup time < 5 segundos
- ✅ Frame rate 60 FPS
- ✅ Memory < 200MB en app promedio
- ✅ Batch size en release
- ✅ Images optimizadas
- ✅ Streams y timers limpios
- ✅ Lazy loading implementado
- ✅ const widgets usados
- ✅ Monitoring activo
- ✅ Profiling regular

---

## Ejercicios

### Ejercicio 1: Optimizar Lista Lenta
Tomar una ListView lenta y optimizarla

### Ejercicio 2: Monitoreo de Memory
Crear app que monitoree memory usage

### Ejercicio 3: Lazy Loading
Implementar pagination y lazy loading

---

## Resumen

Performance optimization es esencial para:
- ✅ Experiencia fluida
- ✅ Batería eficiente
- ✅ Memory adecuada
- ✅ Startup rápido
- ✅ Aplicaciones profesionales
