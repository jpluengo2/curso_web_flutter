# Testing en Flutter: Guía Completa

## Introducción al Testing en Flutter

El testing es fundamental para crear aplicaciones robustas, mantenibles y confiables. Flutter proporciona herramientas completas para realizar tres tipos de testing: **unit tests**, **widget tests** e **integration tests**.

### ¿Por qué es importante el Testing?

- **Detectar bugs temprano**: Antes de que lleguen a producción
- **Refactorización segura**: Cambiar código con confianza
- **Documentación viva**: Los tests actúan como ejemplos de uso
- **Confiabilidad**: Asegurar que la app funciona como se espera
- **Mantenimiento**: Facilita el trabajo en equipo

### Pirámide de Testing

```
         /\
        /  \      Integration Tests (Pocos, lentos)
       /    \
      /______\
     /        \
    /  Widget  \    Widget Tests (Moderados)
   /   Tests    \
  /____________\
 /              \
/ Unit Tests    \   Unit Tests (Muchos, rápidos)
/________________\
```

---

## 1. Unit Tests

Los unit tests prueban funciones, métodos y clases de forma aislada.

### 1.1 Setup Básico

Primero, asegúrate de tener la dependencia en `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 1.2 Estructura de un Unit Test

```dart
// lib/services/calculator.dart
class Calculator {
  int add(int a, int b) => a + b;
  int subtract(int a, int b) => a - b;
  int multiply(int a, int b) => a * b;
  double divide(int a, int b) {
    if (b == 0) throw ArgumentError('No se puede dividir por cero');
    return a / b;
  }
}

// test/services/calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/services/calculator.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;

    // Setup - Se ejecuta antes de cada test
    setUp(() {
      calculator = Calculator();
    });

    // Teardown - Se ejecuta después de cada test
    tearDown(() {
      // Limpiar recursos si es necesario
    });

    group('add', () {
      test('debe sumar dos números positivos', () {
        // Arrange
        final a = 5;
        final b = 3;

        // Act
        final resultado = calculator.add(a, b);

        // Assert
        expect(resultado, 8);
      });

      test('debe sumar números negativos', () {
        expect(calculator.add(-5, -3), -8);
      });

      test('debe sumar cero', () {
        expect(calculator.add(0, 5), 5);
      });
    });

    group('subtract', () {
      test('debe restar dos números', () {
        expect(calculator.subtract(10, 3), 7);
      });

      test('debe restar resultando en negativo', () {
        expect(calculator.subtract(3, 10), -7);
      });
    });

    group('multiply', () {
      test('debe multiplicar dos números', () {
        expect(calculator.multiply(4, 5), 20);
      });

      test('debe multiplicar por cero', () {
        expect(calculator.multiply(5, 0), 0);
      });

      test('debe multiplicar números negativos', () {
        expect(calculator.multiply(-3, -4), 12);
      });
    });

    group('divide', () {
      test('debe dividir dos números', () {
        expect(calculator.divide(10, 2), 5.0);
      });

      test('debe lanzar error al dividir por cero', () {
        expect(
          () => calculator.divide(10, 0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
```

### 1.3 Testing de Servicios API

```dart
// lib/services/user_service.dart
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class UserService {
  Future<User> fetchUser(int id) async {
    // Simular petición HTTP
    await Future.delayed(Duration(milliseconds: 100));
    
    if (id <= 0) {
      throw ArgumentError('ID debe ser positivo');
    }
    
    return User(
      id: id,
      name: 'John Doe',
      email: 'john@example.com',
    );
  }

  List<User> parseUsers(List<dynamic> jsonList) {
    return jsonList
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// test/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/services/user_service.dart';

void main() {
  group('UserService', () {
    late UserService userService;

    setUp(() {
      userService = UserService();
    });

    group('fetchUser', () {
      test('debe retornar un usuario válido', () async {
        final user = await userService.fetchUser(1);

        expect(user.id, 1);
        expect(user.name, 'John Doe');
        expect(user.email, 'john@example.com');
      });

      test('debe lanzar error con ID inválido', () async {
        expect(
          () => userService.fetchUser(-1),
          throwsArgumentError,
        );
      });

      test('debe respetar el timeout', () async {
        final stopwatch = Stopwatch()..start();
        await userService.fetchUser(1);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('parseUsers', () {
      test('debe parsear una lista de usuarios', () {
        final jsonList = [
          {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
          {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        ];

        final users = userService.parseUsers(jsonList);

        expect(users.length, 2);
        expect(users[0].name, 'Alice');
        expect(users[1].email, 'bob@example.com');
      });

      test('debe manejar lista vacía', () {
        final users = userService.parseUsers([]);
        expect(users, isEmpty);
      });
    });
  });
}
```

### 1.4 Matchers Comunes

```dart
// Igualdad
expect(value, equals(5));
expect(value, 5);

// Comparación numérica
expect(value, greaterThan(0));
expect(value, lessThan(10));
expect(value, greaterThanOrEqualTo(1));

// Strings
expect('hello', startsWith('hel'));
expect('hello', endsWith('lo'));
expect('hello', contains('ll'));
expect('hello', matches(RegExp(r'h.*o')));

// Colecciones
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, contains(5));
expect(list, hasLength(3));
expect(list, orderedEquals([1, 2, 3]));

// Booleanos
expect(value, isTrue);
expect(value, isFalse);

// Tipos
expect(value, isA<String>());
expect(value, isA<int>());

// Null
expect(value, isNull);
expect(value, isNotNull);

// Excepciones
expect(() => func(), throwsException);
expect(() => func(), throwsArgumentError);
expect(() => func(), throwsA(isA<CustomException>()));

// Predicados personalizados
expect(value, predicate<int>((v) => v > 0 && v < 100));
```

---

## 2. Widget Tests

Los widget tests prueban widgets de forma aislada, sin necesidad de un dispositivo real.

### 2.1 Estructura Básica de un Widget Test

```dart
// lib/widgets/counter_widget.dart
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _decrement() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contador: $_counter',
              key: const Key('counter_text'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  key: const Key('decrement_button'),
                  onPressed: _decrement,
                  child: const Text('Decrementar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  key: const Key('increment_button'),
                  onPressed: _increment,
                  child: const Text('Incrementar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// test/widgets/counter_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/widgets/counter_widget.dart';

void main() {
  group('CounterWidget', () {
    testWidgets('debe mostrar contador inicial en 0', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      // Assert
      expect(find.text('Contador: 0'), findsOneWidget);
    });

    testWidgets('debe incrementar cuando se presiona el botón', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      // Act
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();

      // Assert
      expect(find.text('Contador: 1'), findsOneWidget);
    });

    testWidgets('debe decrementar cuando se presiona el botón', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      // Primero incrementar a 5
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('increment_button')));
        await tester.pump();
      }

      expect(find.text('Contador: 5'), findsOneWidget);

      // Act - Decrementar
      await tester.tap(find.byKey(const Key('decrement_button')));
      await tester.pump();

      // Assert
      expect(find.text('Contador: 4'), findsOneWidget);
    });

    testWidgets('no debe decrementar por debajo de 0', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      // Act
      await tester.tap(find.byKey(const Key('decrement_button')));
      await tester.pump();

      // Assert
      expect(find.text('Contador: 0'), findsOneWidget);
    });

    testWidgets('debe mostrar AppBar con título', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CounterWidget()),
      );

      expect(find.text('Contador'), findsOneWidget);
    });
  });
}
```

### 2.2 Testing de Formularios

```dart
// lib/widgets/login_form.dart
class LoginForm extends StatefulWidget {
  final Function(String email, String password)? onSubmit;

  const LoginForm({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await Future.delayed(Duration(seconds: 1));
      
      widget.onSubmit?.call(_emailController.text, _passwordController.text);
      
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: const Key('email_field'),
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'El email es requerido';
              }
              if (!value!.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('password_field'),
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'La contraseña es requerida';
              }
              if (value!.length < 6) {
                return 'Mínimo 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('submit_button'),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Ingresar'),
          ),
        ],
      ),
    );
  }
}

// test/widgets/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/widgets/login_form.dart';

void main() {
  group('LoginForm', () {
    testWidgets('debe mostrar campos de email y contraseña', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('debe validar email vacío', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('El email es requerido'), findsOneWidget);
    });

    testWidgets('debe validar email inválido', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'email_invalido',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('debe validar contraseña corta', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        '123',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('debe enviar formulario válido', 
      (WidgetTester tester) async {
      String? emailCapturado;
      String? passwordCapturada;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onSubmit: (email, password) {
                emailCapturado = email;
                passwordCapturada = password;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(emailCapturado, 'test@example.com');
      expect(passwordCapturada, 'password123');
    });
  });
}
```

### 2.3 Métodos Comunes en Widget Tests

```dart
// Encontrar widgets
find.byType(FloatingActionButton);
find.byKey(Key('my_key'));
find.byIcon(Icons.add);
find.text('Hello');
find.byTooltip('Increment');
find.byWidgetPredicate((widget) => widget is Text);

// Interactuar con widgets
await tester.tap(finder);
await tester.longPress(finder);
await tester.doubleClick(finder);
await tester.enterText(finder, 'text');
await tester.pumpWidget(widget);
await tester.pump();
await tester.pumpAndSettle();

// Verificaciones
expect(find.text('Hello'), findsOneWidget);
expect(find.text('Hello'), findsNWidgets(2));
expect(find.text('Hello'), findsNothing);
expect(find.text('Hello'), findsWidgets);

// Screenshots
await tester.binding.takeScreenshot('screenshot_name');

// Gestos
await tester.drag(finder, Offset(0, -100));
await tester.fling(finder, Offset(0, -200), 1000);
await tester.scroll(finder, Offset(0, -100));
```

---

## 3. Integration Tests

Los integration tests prueban la app completa en un dispositivo real o emulador.

### 3.1 Setup

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

Crea la carpeta `integration_test/` en la raíz del proyecto.

### 3.2 Test de Navegación Completa

```dart
// integration_test/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Test', () {
    testWidgets('Flujo completo de la aplicación', 
      (WidgetTester tester) async {
      // Cargar la app
      app.main();
      await tester.pumpAndSettle();

      // Verificar pantalla inicial
      expect(find.text('Home'), findsOneWidget);

      // Navegar a otra pantalla
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Menú'), findsOneWidget);

      // Seleccionar una opción del menú
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('Mi Perfil'), findsOneWidget);

      // Llenar un formulario
      await tester.enterText(
        find.byType(TextField).first,
        'Juan',
      );
      await tester.pumpAndSettle();

      // Guardar
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verificar éxito
      expect(find.text('Guardado exitosamente'), findsOneWidget);

      // Volver a home
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Manejo de errores de red', 
      (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simular acción que requiere red
      await tester.tap(find.text('Cargar datos'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verificar mensaje de error
      expect(find.text('Error de conexión'), findsOneWidget);
    });
  });
}
```

**Ejecutar integration tests:**
```bash
# En dispositivo/emulador conectado
flutter test integration_test/app_flow_test.dart

# En web
flutter test integration_test/app_flow_test.dart -d chrome

# En Windows/Linux/macOS
flutter test integration_test/app_flow_test.dart -d linux
```

### 3.3 Test con Mock de Servicios

```dart
// test/mocks/mock_user_service.dart
import 'package:mockito/mockito.dart';
import 'package:mi_app/services/user_service.dart';

class MockUserService extends Mock implements UserService {}

// test/services/repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mi_app/repositories/user_repository.dart';
import 'package:mi_app/services/user_service.dart';
import 'mocks/mock_user_service.dart';

void main() {
  group('UserRepository', () {
    late MockUserService mockUserService;
    late UserRepository repository;

    setUp(() {
      mockUserService = MockUserService();
      repository = UserRepository(mockUserService);
    });

    test('debe retornar usuario desde el servicio', () async {
      // Arrange
      final expectedUser = User(
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
      );

      when(mockUserService.fetchUser(1))
          .thenAnswer((_) async => expectedUser);

      // Act
      final user = await repository.getUser(1);

      // Assert
      expect(user, expectedUser);
      verify(mockUserService.fetchUser(1)).called(1);
    });

    test('debe cachear usuario después de primera llamada', () async {
      // Arrange
      final expectedUser = User(
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
      );

      when(mockUserService.fetchUser(1))
          .thenAnswer((_) async => expectedUser);

      // Act
      await repository.getUser(1);
      await repository.getUser(1);
      await repository.getUser(1);

      // Assert - Debe llamarse solo una vez gracias al cache
      verify(mockUserService.fetchUser(1)).called(1);
    });

    test('debe lanzar excepción si el servicio falla', () async {
      // Arrange
      when(mockUserService.fetchUser(1))
          .thenThrow(Exception('Error de conexión'));

      // Act & Assert
      expect(
        () => repository.getUser(1),
        throwsException,
      );
    });
  });
}
```

---

## 4. Coverage y Reporting

### 4.1 Generar Coverage Report

```bash
# Instalar lcov (en Windows con Chocolatey)
choco install lcov

# Generar coverage
flutter test --coverage

# Ver resultados
genhtml coverage/lcov.info -o coverage/
start coverage/index.html  # En Windows
open coverage/index.html   # En macOS
```

### 4.2 Archivo de Configuración

```yaml
# coverage_filter.yaml
# Excluir archivos del coverage
- '**/main.dart'
- '**/generated/**'
- '**/*.g.dart'
- '**/*.freezed.dart'
```

---

## 5. Best Practices en Testing

### 5.1 Arrange-Act-Assert (AAA)

```dart
test('debe hacer algo', () {
  // Arrange - Preparar datos y mocks
  final value = 5;
  
  // Act - Ejecutar código a probar
  final result = multiply(value, 2);
  
  // Assert - Verificar resultados
  expect(result, 10);
});
```

### 5.2 Test Names Claros

```dart
// ❌ Malo
test('test1', () {});

// ✅ Bueno
test('debe sumar dos números positivos correctamente', () {});
test('debe lanzar ArgumentError cuando se divide por cero', () {});
test('debe cachear resultados de consultas previas', () {});
```

### 5.3 Evitar Dependencias Entre Tests

```dart
// ❌ Malo
int counter = 0;
test('test 1', () {
  counter++;
  expect(counter, 1);
});
test('test 2', () {
  expect(counter, 1); // Depende del resultado de test 1
});

// ✅ Bueno
test('test 1', () {
  int counter = 0;
  counter++;
  expect(counter, 1);
});
test('test 2', () {
  int counter = 0;
  expect(counter, 0);
});
```

### 5.4 Usar setUp y tearDown

```dart
group('Resource Management', () {
  late File tempFile;

  setUp(() {
    tempFile = File('temp.txt');
    tempFile.writeAsStringSync('data');
  });

  tearDown(() {
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  });

  test('debe usar recurso temporal', () {
    expect(tempFile.readAsStringSync(), 'data');
  });
});
```

### 5.5 Test Widget Performance

```dart
testWidgets('debe renderizar rápidamente', 
  (WidgetTester tester) async {
  final stopwatch = Stopwatch()..start();

  await tester.pumpWidget(const MyApp());

  stopwatch.stop();

  // Debe renderizar en menos de 100ms
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

### 5.6 Cobertura de Errores

```dart
test('debe manejar todas las excepciones posibles', () async {
  expect(
    () => riskyFunction(),
    throwsA(isA<CustomException>()),
  );

  expect(
    () => anotherFunction(),
    throwsA(isA<TimeoutException>()),
  );

  expect(
    () => thirdFunction(),
    throwsA(isA<FormatException>()),
  );
});
```

---

## 6. Herramientas Útiles

### 6.1 Mockito

```dart
import 'package:mockito/mockito.dart';

class MockService extends Mock implements MyService {}

test('test con mock', () {
  final mock = MockService();
  
  when(mock.getData()).thenReturn('mocked data');
  
  final result = mock.getData();
  
  expect(result, 'mocked data');
  verify(mock.getData()).called(1);
});
```

### 6.2 Faker para Datos

```yaml
dev_dependencies:
  faker: ^2.0.0
```

```dart
import 'package:faker/faker.dart';

test('genera datos falsos realistas', () {
  final name = faker.person.name();
  final email = faker.internet.email();
  final phone = faker.phoneNumber.us();
  
  print('$name, $email, $phone');
  // John Doe, john@example.com, (123) 456-7890
});
```

### 6.3 Bloc Test

```yaml
dev_dependencies:
  bloc_test: ^9.0.0
```

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('CounterBloc', () {
    late CounterBloc counterBloc;

    setUp(() {
      counterBloc = CounterBloc();
    });

    testWidgets('emite [1] cuando IncrementEvent se agrega', 
      (WidgetTester tester) async {
      blocTest<CounterBloc, int>(
        'emite [1]',
        build: () => counterBloc,
        act: (bloc) => bloc.add(IncrementEvent()),
        expect: () => [1],
      );
    });
  });
}
```

---

## 7. Ejercicios Prácticos

### Ejercicio 1: Validador de Email
Crea un servicio que valide emails y escribe tests para:
- Email válido
- Email sin @
- Email sin dominio
- Email vacío

### Ejercicio 2: Sistema de Carrito
Crea un widget de carrito de compras con tests para:
- Agregar producto
- Remover producto
- Actualizar cantidad
- Calcular total

### Ejercicio 3: Authenticación
Crea un flujo de login con tests de integración que:
- Llene el formulario correctamente
- Valide errores
- Navegue al home tras éxito
- Maneje errores de red

---

## Checklist de Testing

- ✅ Pruebas unitarias para lógica de negocio
- ✅ Pruebas de widget para UI
- ✅ Pruebas de integración para flujos completos
- ✅ Coverage mínimo del 80%
- ✅ Tests nombrados claramente
- ✅ Uso de Arrange-Act-Assert
- ✅ Mocks para dependencias externas
- ✅ Teardown para limpiar recursos
- ✅ Tests independientes entre sí
- ✅ CI/CD configurado para ejecutar tests

---

## Resumen

El testing en Flutter es esencial para:
- **Confiabilidad**: Asegurar que el código funciona
- **Mantenibilidad**: Cambiar código sin miedo
- **Documentación**: Los tests sirven como ejemplos
- **Calidad**: Detectar bugs temprano

Usa la pirámide de testing: muchos unit tests, moderados widget tests, pocos integration tests.
