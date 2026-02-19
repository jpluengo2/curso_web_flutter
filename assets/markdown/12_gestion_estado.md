# Gestión de Estado en Flutter - Guía Completa

## 📚 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Conceptos fundamentales](#conceptos-fundamentales)
3. [Provider](#provider)
4. [Riverpod](#riverpod)
5. [GetX](#getx)
6. [Bloc/Cubit](#bloccubit)
7. [MobX](#mobx)
8. [Redux](#redux)
9. [StateManagement simple](#statemanagement-simple)
10. [Comparativa de paquetes](#comparativa-de-paquetes)
11. [Ejemplos prácticos](#ejemplos-prácticos)
12. [Mejores prácticas](#mejores-prácticas)

---

## Introducción

La **gestión de estado** es uno de los temas más importantes en desarrollo de aplicaciones Flutter. Es la forma de mantener, actualizar y compartir datos entre diferentes partes de tu aplicación.

### ¿Por qué es importante?

- **Sincronización**: Mantener datos sincronizados en toda la app
- **Rendimiento**: Actualizar solo lo necesario
- **Mantenibilidad**: Código más organizado y fácil de entender
- **Testability**: Código más fácil de probar
- **Escalabilidad**: Aplicaciones que crecen sin caos

### Ejemplo del problema

```dart
// ❌ SIN GESTIÓN DE ESTADO
// Los datos se pierden al cambiar de pantalla
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int contador = 0; // Este valor se pierde cuando navegas

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Contador: $contador'),
        ElevatedButton(
          onPressed: () {
            setState(() => contador++);
          },
          child: Text('Incrementar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, 
              MaterialPageRoute(builder: (_) => OtraScreen())
            );
          },
          child: Text('Ir a otra pantalla'),
        ),
      ],
    );
  }
}

// ✅ CON GESTIÓN DE ESTADO
// Los datos persisten sin importar dónde estés
// (Ver ejemplos abajo con Provider, Riverpod, etc)
```

---

## Conceptos fundamentales

### ¿Qué es el estado?

El **estado** es cualquier dato que puede cambiar en tu aplicación:

```dart
// ESTADO:
int contador = 0;           // Número
String nombre = "Juan";     // Texto
bool esLogueado = false;    // Booleano
List<User> usuarios = [];   // Listas
Map config = {};            // Mapas
```

### Tipos de estado

```
┌─────────────────────────────────────────────────────┐
│           TIPOS DE ESTADO EN FLUTTER                │
├─────────────────────────────────────────────────────┤
│                                                      │
│ 1. ESTADO LOCAL                                      │
│    └─ Afecta un solo widget                          │
│    └─ Ej: isHovered, isExpanded                      │
│                                                      │
│ 2. ESTADO DE APLICACIÓN                              │
│    └─ Afecta múltiples pantallas                     │
│    └─ Ej: usuario logueado, tema, idioma             │
│                                                      │
│ 3. ESTADO DE WIDGET                                  │
│    └─ Compartido entre widgets hermanos              │
│    └─ Ej: datos de un formulario                     │
│                                                      │
│ 4. ESTADO DE CACHÉ                                   │
│    └─ Datos guardados persistentemente                │
│    └─ Ej: preferencias, tokens                       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Soluciones comunes

```
Según la escala:

Pequeña app (1-5 pantallas)     → setState() o GetX
App media (5-20 pantallas)      → Provider o Riverpod
App grande (20+ pantallas)      → Bloc/Cubit o Riverpod
```

---

## Provider

Provider es la solución más popular para gestión de estado en Flutter. Es simple, poderosa y bien documentada.

### Instalación

En `pubspec.yaml`:

```yaml
dependencies:
  provider: ^6.0.0
  flutter_riverpod: # Si usas Riverpod
```

### Concepto básico: ChangeNotifier

```dart
import 'package:flutter/foundation.dart';

// Crear un modelo con ChangeNotifier
class CounterProvider extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners(); // Notificar a los listeners
  }

  void decrement() {
    _counter--;
    notifyListeners();
  }

  void reset() {
    _counter = 0;
    notifyListeners();
  }
}
```

### Uso básico de Provider

```dart
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Crear instancia del provider
        ChangeNotifierProvider(
          create: (_) => CounterProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Escuchar cambios con Consumer
            Consumer<CounterProvider>(
              builder: (context, counter, _) {
                return Text(
                  'Contador: ${counter.counter}',
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
            SizedBox(height: 20),
            // Otra forma: usar context.watch()
            ElevatedButton(
              onPressed: () {
                // Acceder sin escuchar
                context.read<CounterProvider>().increment();
              },
              child: Text('Incrementar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CounterProvider>().decrement();
              },
              child: Text('Decrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### watch() vs read()

```dart
// ✅ watch(): Escucha cambios, reconstruye el widget
int contador = context.watch<CounterProvider>().counter;

// ✅ read(): Lee el valor sin escuchar, no reconstruye
context.read<CounterProvider>().increment();

// ❌ watch() en onPressed: Error
ElevatedButton(
  onPressed: () {
    context.watch<CounterProvider>().increment(); // ❌ MAL
  },
  child: Text('...'),
)

// ✅ Usar read()
ElevatedButton(
  onPressed: () {
    context.read<CounterProvider>().increment(); // ✅ BIEN
  },
  child: Text('...'),
)
```

### Ejemplo: Autenticación con Provider

```dart
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      // Simulación de API call
      await Future.delayed(Duration(seconds: 1));
      
      _isLoggedIn = true;
      _token = 'fake_token_123';
      _user = User(email: email, name: 'Usuario');
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _user = null;
    notifyListeners();
  }
}

class User {
  final String email;
  final String name;

  User({required this.email, required this.name});
}

// En main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

// En un Widget
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 32),
            // Botón que espera el login
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return ElevatedButton(
                  onPressed: () async {
                    try {
                      await auth.login(
                        emailController.text,
                        passwordController.text,
                      );
                      // Navegar a home
                      Navigator.pushReplacementNamed(context, '/home');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text('Entrar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
```

### Tipos de Provider

```dart
// 1. ChangeNotifierProvider: Para ChangeNotifier
ChangeNotifierProvider(create: (_) => CounterProvider())

// 2. StateProvider: Para valores simples
StateProvider((ref) => 0)

// 3. FutureProvider: Para valores asincronos
FutureProvider((ref) async {
  return await fetchData();
})

// 4. StreamProvider: Para streams
StreamProvider((ref) {
  return dataStream();
})

// 5. ProxyProvider: Combinar múltiples providers
ProxyProvider<AuthProvider, UserProvider>(
  update: (_, auth, __) => UserProvider(auth.user),
)
```

---

## Riverpod

Riverpod es la nueva generación de gestión de estado en Flutter. Es más poderosa que Provider y soporta null-safety mejor.

### Instalación

En `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.2.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### Concepto básico: Providers

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Crear un provider simple
final counterProvider = StateProvider<int>((ref) => 0);

// Usar en un widget
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar el estado
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Riverpod')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $counter', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Actualizar el estado
                ref.read(counterProvider.notifier).state++;
              },
              child: Text('Incrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Tipos de Providers en Riverpod

```dart
// 1. Provider: Solo lectura
final nameProvider = Provider((ref) => "Juan");

// 2. StateProvider: Lectura y escritura
final counterProvider = StateProvider((ref) => 0);

// 3. FutureProvider: Para operaciones asincronas
final userProvider = FutureProvider((ref) async {
  return await fetchUser();
});

// 4. StreamProvider: Para streams
final chatProvider = StreamProvider((ref) {
  return chatStream();
});

// 5. StateNotifierProvider: Estado complejo
final todoProvider = StateNotifierProvider((ref) {
  return TodoNotifier();
});

// 6. ProviderFamily: Parámetros dinámicos
final productProvider = FutureProvider.family((ref, id) async {
  return await fetchProduct(id);
});
```

### Ejemplo completo con Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definir providers
final counterProvider = StateProvider<int>((ref) => 0);

final isEvenProvider = Provider<bool>((ref) {
  final counter = ref.watch(counterProvider);
  return counter % 2 == 0;
});

// Usar en widget (ConsumerWidget)
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final isEven = ref.watch(isEvenProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Riverpod')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $counter', style: TextStyle(fontSize: 24)),
            Text('Es par: $isEven'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(counterProvider.notifier).state++;
              },
              child: Text('Incrementar'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(counterProvider.notifier).state = 0;
              },
              child: Text('Resetear'),
            ),
          ],
        ),
      ),
    );
  }
}

// Envolver la app con ProviderScope
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Autenticación con Riverpod

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      await Future.delayed(Duration(seconds: 1));
      final user = User(email: email, name: 'Usuario');
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error('Error: $e');
    }
  }

  Future<void> logout() async {
    state = AuthState.initial();
  }
}

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({
    required this.isLoading,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(isLoading: false);
  }

  factory AuthState.loading() {
    return AuthState(isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(isLoading: false, user: user);
  }

  factory AuthState.error(String error) {
    return AuthState(isLoading: false, error: error);
  }

  bool get isAuthenticated => user != null;
}

class User {
  final String email;
  final String name;

  User({required this.email, required this.name});
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// En un widget
class LoginScreen extends ConsumerWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 32),
            if (authState.isLoading)
              CircularProgressIndicator()
            else if (authState.error != null)
              Text('Error: ${authState.error}')
            else
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).login(
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: Text('Entrar'),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## GetX

GetX es un paquete muy versátil que proporciona gestión de estado, rutas y dependencias todo en uno.

### Instalación

En `pubspec.yaml`:

```yaml
dependencies:
  get: ^4.6.0
```

### Uso básico

```dart
import 'package:get/get.dart';

// Crear un controller
class CounterController extends GetxController {
  var counter = 0.obs; // .obs hace observable

  void increment() {
    counter++;
  }

  void decrement() {
    counter--;
  }
}

// En main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: HomePage(),
    );
  }
}

// En un widget
class HomePage extends StatelessWidget {
  // Instanciar el controller
  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GetX')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usar Obx para reactividad
            Obx(() => Text(
              'Contador: ${controller.counter}',
              style: TextStyle(fontSize: 24),
            )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.increment,
              child: Text('Incrementar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.decrement,
              child: Text('Decrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Ventajas de GetX

```dart
// 1. Sintaxis simple y clara
var contador = 0.obs; // Observable

// 2. Reactividad automática
Obx(() => Text('$contador'))

// 3. Sin necesidad de BuildContext
Get.to(OtraScreen())

// 4. Inyección de dependencias
Get.put(Service());
Get.find<Service>();

// 5. Gestión de estado elegante
class MyController extends GetxController {
  var loading = false.obs;
  
  void cambiarLoading() {
    loading.value = !loading.value;
  }
}
```

### Autenticación con GetX

```dart
class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var user = Rxn<User>(); // Nullable observable
  var loading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      loading.value = true;
      await Future.delayed(Duration(seconds: 1));
      
      user.value = User(email: email, name: 'Usuario');
      isLoggedIn.value = true;
      
      Get.offAllNamed('/home'); // Navegar
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    user.value = null;
    isLoggedIn.value = false;
  }
}

class User {
  final String email;
  final String name;

  User({required this.email, required this.name});
}

// En main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: HomePage(),
      getPages: [
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginScreen()),
      ],
    );
  }
}

// En LoginScreen
class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Obx(() => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 32),
            authController.loading.value
              ? CircularProgressIndicator()
              : ElevatedButton(
                onPressed: () {
                  authController.login(
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: Text('Entrar'),
              ),
          ],
        ),
      )),
    );
  }
}
```

---

## Bloc/Cubit

Bloc (Business Logic Component) es un patrón que separa la lógica de negocios de la UI.

### Instalación

En `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
```

### Concepto: Cubit (Versión simple de Bloc)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// Crear un Cubit
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0); // Estado inicial

  void increment() => emit(state + 1); // Emitir nuevo estado
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

// En main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => CounterCubit(),
        child: HomePage(),
      ),
    );
  }
}

// En un widget
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bloc/Cubit')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Escuchar cambios con BlocBuilder
            BlocBuilder<CounterCubit, int>(
              builder: (context, state) {
                return Text(
                  'Contador: $state',
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CounterCubit>().increment();
              },
              child: Text('Incrementar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CounterCubit>().decrement();
              },
              child: Text('Decrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Concepto: Bloc (Con eventos)

```dart
// Definir eventos
abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}
class ResetEvent extends CounterEvent {}

// Crear un Bloc
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<IncrementEvent>((event, emit) => emit(state + 1));
    on<DecrementEvent>((event, emit) => emit(state - 1));
    on<ResetEvent>((event, emit) => emit(0));
  }
}

// Usar en widget
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text('Bloc')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<CounterBloc, int>(
                builder: (context, state) {
                  return Text(
                    'Contador: $state',
                    style: TextStyle(fontSize: 24),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<CounterBloc>().add(IncrementEvent());
                },
                child: Text('Incrementar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Autenticación con Bloc

```dart
// Estados
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}

// Eventos
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

class LogoutEvent extends AuthEvent {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(Duration(seconds: 1));
      final user = User(email: event.email, name: 'Usuario');
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Error: $e'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}

class User {
  final String email;
  final String name;

  User({required this.email, required this.name});
}

// En LoginScreen
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is AuthLoading)
                      CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            LoginEvent('user@example.com', 'password'),
                          );
                        },
                        child: Text('Entrar'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

---

## MobX

MobX es un sistema reactivo basado en observables. Muy poderoso pero más complejo.

### Instalación

En `pubspec.yaml`:

```yaml
dependencies:
  mobx: ^2.2.0
  flutter_mobx: ^2.0.0

dev_dependencies:
  mobx_codegen: ^2.1.0
  build_runner: ^2.4.0
```

### Uso básico

```dart
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

part 'counter_store.g.dart';

// Crear el store
class CounterStore = CounterStoreBase with _$CounterStore;

abstract class CounterStoreBase with Store {
  @observable
  int counter = 0;

  @action
  void increment() {
    counter++;
  }

  @action
  void decrement() {
    counter--;
  }

  @computed
  bool get isEven => counter % 2 == 0;
}

// Generar código
// flutter pub run build_runner build

// En main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final counterStore = CounterStore();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(store: counterStore),
    );
  }
}

// En un widget
class HomePage extends StatelessWidget {
  final CounterStore store;

  const HomePage({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MobX')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Observer para reactividad
            Observer(
              builder: (_) => Text(
                'Contador: ${store.counter}',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Observer(
              builder: (_) => Text('Es par: ${store.isEven}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: store.increment,
              child: Text('Incrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Generación de código

```bash
flutter pub run build_runner build
```

---

## Redux

Redux es un patrón para gestión de estado inmutable. Usado en aplicaciones muy grandes.

### Instalación

En `pubspec.yaml`:

```yaml
dependencies:
  redux: ^5.0.0
  flutter_redux: ^0.10.0
```

### Estructura básica

```dart
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

// 1. Definir el estado
class AppState {
  final int counter;

  AppState({required this.counter});

  factory AppState.initial() {
    return AppState(counter: 0);
  }

  AppState copyWith({int? counter}) {
    return AppState(counter: counter ?? this.counter);
  }
}

// 2. Definir acciones
class IncrementAction {}
class DecrementAction {}
class ResetAction {}

// 3. Crear reducers
final counterReducer = combineReducers<int>([
  TypedReducer<int, IncrementAction>(_increment),
  TypedReducer<int, DecrementAction>(_decrement),
  TypedReducer<int, ResetAction>(_reset),
]);

int _increment(int state, IncrementAction action) => state + 1;
int _decrement(int state, DecrementAction action) => state - 1;
int _reset(int state, ResetAction action) => 0;

// 4. Crear el store
final appReducer = combineReducers<AppState>([
  TypedReducer<AppState, dynamic>(_appStateReducer),
]);

AppState _appStateReducer(AppState state, dynamic action) {
  return state.copyWith(
    counter: counterReducer(state.counter, action),
  );
}

// 5. Usar en main.dart
void main() {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
  );

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

// 6. En widgets
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      converter: (store) => store.state.counter,
      builder: (context, counter) {
        return Scaffold(
          appBar: AppBar(title: Text('Redux')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Contador: $counter', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    StoreProvider.of<AppState>(context).dispatch(IncrementAction());
                  },
                  child: Text('Incrementar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## StateManagement simple

A veces no necesitas un paquete complejo. Una solución simple puede ser suficiente.

### Patrón simple con ChangeNotifier

```dart
import 'package:flutter/foundation.dart';

// 1. Crear un modelo
class AppState extends ChangeNotifier {
  int _counter = 0;
  bool _isDarkMode = false;

  int get counter => _counter;
  bool get isDarkMode => _isDarkMode;

  void increment() {
    _counter++;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// 2. Usar con inheritedWidget
class AppStateProvider extends InheritedWidget {
  final AppState state;

  const AppStateProvider({
    required this.state,
    required Widget child,
  }) : super(child: child);

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    return provider!.state;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) {
    return true;
  }
}

// 3. En main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: appState,
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    appState.dispose();
    super.dispose();
  }
}

// 4. En widgets
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Simple State')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: ${appState.counter}'),
            ElevatedButton(
              onPressed: appState.increment,
              child: Text('Incrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Comparativa de paquetes

```
┌──────────┬──────────┬──────────┬────────────┬──────────┬───────────┐
│ Paquete  │ Curva    │ Potencia │ Comunidad  │ Deep     │ Casos de  │
│          │ aprendiz │          │            │ linking  │ uso       │
├──────────┼──────────┼──────────┼────────────┼──────────┼───────────┤
│ Provider │ Baja     │ Alta     │ Muy Grande │ Manual   │ General   │
│ Riverpod │ Media    │ Muy Alta │ Grande     │ Manual   │ General   │
│ GetX     │ Baja     │ Alta     │ Grande     │ Integrado│ Rápido    │
│ Bloc     │ Alta     │ Muy Alta │ Muy Grande │ Manual   │ Escalable │
│ MobX     │ Media    │ Alta     │ Media      │ Manual   │ Reactivo  │
│ Redux    │ Muy Alta │ Alta     │ Pequeña    │ Manual   │ Empresas  │
└──────────┴──────────┴──────────┴────────────┴──────────┴───────────┘
```

### Recomendaciones

```
Principiante              → Provider o GetX
App pequeña/mediana      → Provider o Riverpod
App grande/escalable     → Bloc o Riverpod
Desarrollo rápido        → GetX
Equipo experimentado     → Bloc o Redux
Reactividad avanzada     → MobX
Aplicación empresarial   → Bloc o Redux
```

---

## Ejemplos prácticos

### Ejemplo: Carrito de compras con Provider

```dart
class ProductModel {
  final int id;
  final String name;
  final double price;
  int quantity;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => _items;

  double get total {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  void addProduct(ProductModel product) {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeProduct(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }  

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Usar en UI
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrito')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('\$${item.price}'),
                      trailing: Text('x${item.quantity}'),
                      onLongPress: () {
                        cart.removeProduct(item.id);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Total: \$${cart.total.toStringAsFixed(2)}'),
                    ElevatedButton(
                      onPressed: cart.items.isEmpty
                        ? null
                        : () {
                          // Procesar compra
                          cart.clearCart();
                        },
                      child: Text('Comprar'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### Ejemplo: Tema oscuro/claro con Riverpod

```dart
final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(title: Text('Tema')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              ref.read(themeProvider.notifier).state =
                isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
            child: Text(isDarkMode ? 'Modo Claro' : 'Modo Oscuro'),
          ),
        ),
      ),
    );
  }
}
```

---

## Mejores prácticas

### ✅ DO: Hacer esto

```dart
// Usar providers para datos compartidos
final userProvider = StateProvider<User?>((ref) => null);

// Separar lógica de negocio de UI
class UserNotifier extends StateNotifier<User> {
  // Lógica aquí
}

// Usar tipos específicos
FutureProvider<List<User>> vs Provider<dynamic>

// Escuchar solo lo necesario
ref.watch(userProvider.select((user) => user.name))

// Usar .family para parámetros
FutureProvider.family<User, int>((ref, userId) async {
  return await fetchUser(userId);
})

// Documentar providers complejos
/// Proporciona la lista de usuarios con cache
final usersProvider = FutureProvider<List<User>>(...)

// Manejar errores correctamente
try {
  final data = await fetchData();
  emit(SuccessState(data));
} catch (e) {
  emit(ErrorState(e.toString()));
}
```

### ❌ DON'T: No hacer esto

```dart
// ✗ No mezclar múltiples soluciones de estado
Provider + Riverpod + GetX en la misma app

// ✗ No pasar contexto a través de providers
Provider<BuildContext>

// ✗ No modificar estado desde UI sin lógica
state.items.add(item); // Mutación

// ✗ No ignorar el null safety
FutureProvider<List<User>> cuando puede ser null

// ✗ No usar setState si tienes gestión de estado
setState(() => variable++)

// ✗ No crear providers en widgets
// Siempre en el nivel de app o archivo separado

// ✗ No usar watch en callbacks
onPressed: () {
  context.watch<Provider>() // ✗ MAL
}

// ✓ Usar read
onPressed: () {
  context.read<Provider>()
}
```

### Checklist de mejores prácticas

- [ ] Elegir un patrón y usarlo consistentemente
- [ ] Separar lógica de negocio de UI
- [ ] Manejar estados de carga y error
- [ ] Usar tipos específicos, no dynamic
- [ ] Documentar providers complejos
- [ ] Probar la lógica de negocio independientemente
- [ ] Evitar mezclar múltiples soluciones
- [ ] Usar watch/read correctamente
- [ ] Manejar el ciclo de vida del estado
- [ ] Considerar el rendimiento (rebuilds innecesarios)

---

## Resumen y recomendaciones finales

```
Para empezar:        → Provider
Para modernidad:     → Riverpod
Para velocidad:      → GetX
Para escala:         → Bloc
Para reactividad:    → MobX
Para empresas:       → Redux/Bloc
Para simplicidad:    → setState + InheritedWidget
```

**La mejor solución es la que se ajusta a tu proyecto y equipo.** No existe "la mejor", solo la que funciona mejor para TU caso específico.

---

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio/Avanzado**
