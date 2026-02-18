# Riverpod: State Management Moderno en Flutter

## Introducción a Riverpod

Riverpod es la evolución moderna de Provider, ofreciendo:

- ✅ Type-safe
- ✅ Testeable
- ✅ Scope management
- ✅ Invalidation
- ✅ Override para testing

### Ventajas sobre Provider

| Característica | Provider | Riverpod |
|---|---|---|
| Type Safety | Parcial | ✅ Completo |
| Scope | Manual | ✅ Automático |
| Testing | Complejo | ✅ Simple |
| Invalidation | Manual | ✅ Automático |
| Family | ✅ Sí | ✅ Mejorado |

---

## 1. Setup Inicial

### 1.1 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_generator: ^2.3.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### 1.2 Wrapper Main

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod App',
      home: const HomeScreen(),
    );
  }
}
```

---

## 2. Providers Básicos

### 2.1 StateProvider

```dart
// Proveedor simple (state)
final counterProvider = StateProvider<int>((ref) {
  return 0;
});

// Widget
class Counter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $count'),
            ElevatedButton(
              onPressed: () {
                // Leer y modificar
                ref.read(counterProvider.notifier).state++;
              },
              child: const Text('Incrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.2 FutureProvider

```dart
// Proveedor asíncrono
final userProvider = FutureProvider<User>((ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/user/1'));
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error al cargar usuario');
  }
});

// Widget
class UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (user) => Column(
        children: [
          Text('Nombre: ${user.name}'),
          Text('Email: ${user.email}'),
        ],
      ),
    );
  }
}
```

### 2.3 StreamProvider

```dart
// Proveedor de stream
final messagesProvider = StreamProvider<String>((ref) {
  return messagesStream; // Stream<String>
});

// Widget
class MessagesWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);

    return messages.when(
      loading: () => const Text('Conectando...'),
      error: (err, stack) => Text('Error: $err'),
      data: (message) => Text('Mensaje: $message'),
    );
  }
}
```

### 2.4 StateNotifierProvider

```dart
// Notifier personalizado
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterNotifierProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// Widget
class CounterNotifierWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterNotifierProvider);
    final notifier = ref.read(counterNotifierProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Contador: $count'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: notifier.decrement,
              child: const Text('-'),
            ),
            ElevatedButton(
              onPressed: notifier.reset,
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: notifier.increment,
              child: const Text('+'),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## 3. Providers Avanzados

### 3.1 Family Modifier

```dart
// Parámetro dinámico
final userByIdProvider = FutureProvider.family<User, int>((ref, userId) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/users/$userId'),
  );
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error al cargar usuario');
  }
});

// Widget
class UserDetailsWidget extends ConsumerWidget {
  final int userId;

  const UserDetailsWidget({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (user) => Text('Usuario: ${user.name}'),
    );
  }
}
```

### 3.2 AutoDispose

```dart
// Se descarta cuando no se usa
final temperatureProvider = FutureProvider.autoDispose<double>((ref) async {
  return await fetchTemperature();
});

// Con family y autoDispose
final weatherProvider = FutureProvider.autoDispose.family<Weather, String>(
  (ref, city) async {
    return await fetchWeather(city);
  },
);
```

### 3.3 Select

```dart
// Escuchar solo parte del estado
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});

class UserNameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo escuchar el nombre (evita rebuilds innecesarios)
    final name = ref.watch(
      userProvider.select((userAsync) =>
          userAsync.whenData((user) => user.name).value),
    );

    return Text('Nombre: $name');
  }
}
```

### 3.4 Invalidation

```dart
// Forzar refetch
ElevatedButton(
  onPressed: () {
    ref.refresh(userProvider);
  },
  child: const Text('Recargar'),
)

// Invalidate múltiples providers
ElevatedButton(
  onPressed: () {
    ref.invalidate(userProvider);
    ref.invalidate(postsProvider);
  },
  child: const Text('Refrescar todo'),
)
```

---

## 4. Combinación de Providers

### 4.1 Dependencias entre Providers

```dart
// Usuario actual
final currentUserProvider = FutureProvider<User>((ref) async {
  return fetchCurrentUser();
});

// Posts del usuario actual
final userPostsProvider = FutureProvider<List<Post>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return fetchUserPosts(user.id);
});

// Widget que combina
class UserWithPostsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final postsAsync = ref.watch(userPostsProvider);

    return userAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text('Error: $err'),
      data: (user) => postsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, _) => Text('Error: $err'),
        data: (posts) => Column(
          children: [
            Text('Usuario: ${user.name}'),
            Text('Posts: ${posts.length}'),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Testing con Riverpod

### 5.1 Test Simple

```dart
test('Counter increments correctly', () async {
  final container = ProviderContainer();

  // Leer estado inicial
  var state = container.read(counterProvider);
  expect(state, 0);

  // Modificar estado
  container.read(counterProvider.notifier).state++;

  // Verificar
  state = container.read(counterProvider);
  expect(state, 1);
});

test('Override provider for testing', () async {
  final mockUserProvider = FutureProvider<User>((ref) async {
    return User(id: 1, name: 'Test User', email: 'test@example.com');
  });

  final container = ProviderContainer(
    overrides: [
      userProvider.overrideWithProvider(mockUserProvider),
    ],
  );

  final user = await container.read(userProvider.future);
  expect(user.name, 'Test User');
});
```

### 5.2 Widget Test

```dart
testWidgets('Counter widget test', (WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  expect(find.text('Contador: 0'), findsOneWidget);

  await tester.tap(find.text('+'));
  await tester.pump();

  expect(find.text('Contador: 1'), findsOneWidget);
});
```

---

## 6. Logging y DevTools

### 6.1 Logger Provider

```dart
// Log para debugging
final logProvider = Provider((ref) {
  return RiverpodLogger();
});

class RiverpodLogger {
  void log(String message) {
    print('[Riverpod] $message');
  }
}

// Usar en providers
final userProvider = FutureProvider<User>((ref) async {
  final logger = ref.watch(logProvider);
  logger.log('Cargando usuario...');
  
  final user = await fetchUser();
  logger.log('Usuario cargado: ${user.name}');
  
  return user;
});
```

### 6.2 Observer

```dart
class RiverpodObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('${provider.name} cambió de $previousValue a $newValue');
  }
}

// En main
void main() {
  runApp(
    ProviderScope(
      observers: [RiverpodObserver()],
      child: const MyApp(),
    ),
  );
}
```

---

## 7. Riverpod Generator

### 7.1 Usar @riverpod

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
Future<User> user(UserRef ref, int id) async {
  return fetchUser(id);
}

@riverpod
Future<List<Post>> userPosts(UserPostsRef ref, int userId) async {
  return fetchUserPosts(userId);
}

@riverpod
String greeting(GreetingRef ref, String name) {
  return 'Hola $name';
}

// Ejecutar: dart run build_runner watch
```

### 7.2 Usar Generated Providers

```dart
class UserScreen extends ConsumerWidget {
  final int userId;

  const UserScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    final greeting = ref.watch(greetingProvider('Juan'));

    return userAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text('Error: $err'),
      data: (user) => Column(
        children: [
          Text(greeting),
          Text('Usuario: ${user.name}'),
        ],
      ),
    );
  }
}
```

---

## 8. Best Practices

✅ **DO's:**
- Usar autoDispose para providers que no siempre se usan
- Combinar providers con watch
- Testear providers en aislamiento
- Usar family para parámetros dinámicos
- Implementar error handling
- Usar select para optimizar

❌ **DON'Ts:**
- Acceder a ref fuera de builders
- Crear providers en loops
- Ignorar autoDispose
- No testar providers
- Hacer providers demasiado complejos

---

## 9. Comparativa: Provider vs Riverpod

```dart
// Provider
final counterProvider = StateProvider((ref) => 0);

final incrementProvider = FutureProvider((ref) async {
  ref.watch(counterProvider).state++;
});

// Riverpod
final counter = StateProvider<int>((ref) => 0);

final increment = FutureProvider<void>((ref) async {
---

## 8. Antipatrones en Riverpod

### Antipatrón 1: Rebuilds innecesarios
```dart
// ❌ MALO - Reconstruye todo aunque solo cambie name
Consumer<UserProvider>(
  builder: (context, userProvider, _) {
    return Column(
      children: [
        Text('Nombre: ${userProvider.name}'),
        Container(height: 500, child: const Text('Costoso')),
      ],
    );
  },
)

// ✅ BIEN - Solo escucha name
Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    final name = userProvider.select((p) => p.name);
    return Column(children: [Text('Nombre: $name'), child!], );
  },
  child: Container(height: 500, child: const Text('Costoso')),
)
```

### Antipatrón 2: No usar autoDispose
```dart
// ❌ MALO - Mantiene memoria aunque no se use
final userProvider = FutureProvider<User>((ref) async => fetchUser());

// ✅ BIEN - Se descarta cuando no lo ves
final userProvider = FutureProvider.autoDispose<User>((ref) async => fetchUser());
```

### Antipatrón 3: Modificar lista directamente
```dart
// ❌ MALO - No actualiza
final items = StateProvider<List<String>>((ref) => []);
ref.read(items.notifier).state.add('item'); // ¡No funciona!

// ✅ BIEN - Nueva instancia
ref.read(items.notifier).state = [...state, 'item'];
```

---

## 9. Problemas Comunes

### Problema: "Provider no actualiza"
**Causa:** No llamaste `ref.refresh()` o `ref.invalidate()`  
**Solución:** 
```dart
ref.refresh(userProvider); // Refetch completo
ref.invalidate(userProvider); // Marca como inválido
```

### Problema: "Error en override durante test"
**Causa:** Tipo incorrecto en override  
**Solución:** Usar `.overrideWithProvider()` con tipos explícitos

---

## 10. Patrones Recomendados

### Patrón 1: Feature-based organization
```
features/
  users/
    providers/user_provider.dart
    models/user.dart
    screens/user_screen.dart
```

### Patrón 2: Environment-based config
```dart
final apiUrlProvider = Provider<String>((ref) {
  if (kDebugMode) return 'http://localhost:3000';
  return 'https://api.production.com';
});
```

---

## 📚 Conceptos Relacionados

- [12 Gestión Estado](12_GESTION_ESTADO.md) - Comparativa Provider
- [16 Testing](16_TESTING.md) - Testear providers
- [22 Clean Arch](22_CLEAN_ARCHITECTURE.md) - Riverpod + Clean
- [EJERCICIOS_20](EJERCICIOS_20_RIVERPOD.md) - Prácticas

  ref.read(counter.notifier).state++;
});

// Con generador
@riverpod
int counter(CounterRef ref) => 0;

@riverpod
Future<void> increment(IncrementRef ref) async {
  ref.read(counterNotifier.notifier).state++;
}
```

---

## Resumen

Riverpod proporciona:
- ✅ Type safety completo
- ✅ Testabilidad simple
- ✅ Scope automático
- ✅ Invalidation declarativa
- ✅ Moderno y mantenido
