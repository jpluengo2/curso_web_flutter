# Manejo de Errores en Flutter: Guía Completa

## Introducción al Manejo de Errores

El manejo adecuado de errores es crucial para crear aplicaciones robustas y profesionales. Un buen sistema de manejo de errores:

- **Previene crashes**: La app no se cierra inesperadamente
- **Comunica problemas**: El usuario sabe qué salió mal
- **Facilita debugging**: Los logs ayudan a identificar problemas
- **Mejora UX**: Respuestas claras ante errores
- **Confiabilidad**: La app es predecible y estable

---

## 1. Try-Catch Básico

### 1.1 Estructura Simple

```dart
void basicTryCatch() {
  try {
    // Código que puede lanzar excepción
    int result = 10 ~/ 0; // Error: División por cero
  } catch (e) {
    // Manejar la excepción
    print('Error: $e');
  }
}

void tryCatchWithFinally() {
  try {
    // Código que puede fallar
    openFile();
  } catch (e) {
    print('Error al abrir archivo: $e');
  } finally {
    // Siempre se ejecuta
    print('Limpiando recursos');
  }
}
```

### 1.2 Capturar Tipo Específico de Excepción

```dart
Future<void> fetchDataWithSpecificErrors() async {
  try {
    final response = await http.get(Uri.parse('https://api.example.com/data'));
    
    if (response.statusCode != 200) {
      throw Exception('Error en la solicitud: ${response.statusCode}');
    }
  } on SocketException {
    print('Error de conexión: Verifica tu internet');
  } on TimeoutException {
    print('Error: La solicitud tardó demasiado');
  } on HttpException catch (e) {
    print('Error HTTP: ${e.message}');
  } catch (e) {
    print('Error desconocido: $e');
  }
}

void multipleExceptions() {
  try {
    // Código
  } on FormatException {
    print('Formato inválido');
  } on RangeError {
    print('Rango fuera de límites');
  } on ArgumentError {
    print('Argumento inválido');
  } on Exception catch (e) {
    print('Excepción general: $e');
  } catch (e) {
    print('Error desconocido: $e');
  }
}
```

### 1.3 Stack Trace para Debugging

```dart
void getStackTrace() {
  try {
    riskyFunction();
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace:\n$stackTrace');
    
    // Log en servicio remoto
    logToServer(e, stackTrace);
  }
}

void logToServer(Object error, StackTrace stackTrace) {
  // Enviar a servicio de logging (Firebase, Sentry, etc.)
  print('Enviando error al servidor');
}
```

---

## 2. Excepciones Personalizadas

### 2.1 Crear Excepciones Personalizadas

```dart
// lib/exceptions/app_exceptions.dart

// Excepción base
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

// Excepción de red
class NetworkException extends AppException {
  NetworkException({
    String message = 'Error de conexión',
    String? code,
  }) : super(message: message, code: code);
}

// Excepción de autenticación
class AuthenticationException extends AppException {
  AuthenticationException({
    String message = 'Error de autenticación',
    String? code,
  }) : super(message: message, code: code);
}

// Excepción de validación
class ValidationException extends AppException {
  final Map<String, String> errors;

  ValidationException({
    required this.errors,
    String message = 'Errores de validación',
  }) : super(message: message);
}

// Excepción de servidor
class ServerException extends AppException {
  ServerException({
    String message = 'Error del servidor',
    String? code,
  }) : super(message: message, code: code);
}

// Excepción de datos no encontrados
class NotFoundException extends AppException {
  NotFoundException({
    String message = 'Recurso no encontrado',
    String? code,
  }) : super(message: message, code: code);
}

// Excepción de timeout
class RequestTimeoutException extends AppException {
  RequestTimeoutException({
    String message = 'La solicitud tardó demasiado',
  }) : super(message: message);
}

// Excepción de permisos
class PermissionException extends AppException {
  PermissionException({
    String message = 'Permiso denegado',
  }) : super(message: message);
}
```

### 2.2 Usar Excepciones Personalizadas

```dart
// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:mi_app/exceptions/app_exceptions.dart';

class ApiService {
  Future<Map<String, dynamic>> fetchUser(int id) async {
    try {
      if (id <= 0) {
        throw ValidationException(
          errors: {'id': 'El ID debe ser positivo'},
          message: 'ID inválido',
        );
      }

      // Simular petición HTTP
      final response = await http.get(
        Uri.parse('https://api.example.com/users/$id'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw NotFoundException(
          message: 'Usuario no encontrado',
        );
      }

      if (response.statusCode == 401) {
        throw AuthenticationException(
          message: 'Credenciales inválidas',
        );
      }

      if (response.statusCode == 500) {
        throw ServerException(
          message: 'Error del servidor',
          code: '500',
        );
      }

      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode}');
      }

      return json.decode(response.body);
    } on SocketException {
      throw NetworkException(
        message: 'No hay conexión a internet',
      );
    } on TimeoutException { // Atrapa la excepción de dart:async
      throw RequestTimeoutException( // Lanza nuestra excepción personalizada
        message: 'La solicitud tardó más de 10 segundos',
      );
    } on AppException {
      rethrow; // Re-lanzar excepción personalizada
    } catch (e) {
      throw AppException(
        message: 'Error desconocido: $e',
      );
    }
  }
}
```

### 2.3 Manejar Excepciones en UI

```dart
// lib/screens/user_screen.dart
class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().fetchUser(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuario')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          }

          final userData = snapshot.data;
          return _buildUserWidget(userData);
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    String errorMessage = 'Error desconocido';
    IconData errorIcon = Icons.error;

    if (error is NetworkException) {
      errorMessage = 'No hay conexión a internet';
      errorIcon = Icons.wifi_off;
    } else if (error is NotFoundException) {
      errorMessage = 'Usuario no encontrado';
      errorIcon = Icons.person_off;
    } else if (error is AuthenticationException) {
      errorMessage = 'Autenticación fallida';
      errorIcon = Icons.lock;
    } else if (error is ServerException) {
      errorMessage = 'Error del servidor';
      errorIcon = Icons.cloud_off;
    } else if (error is RequestTimeoutException) {
      errorMessage = error.message;
      errorIcon = Icons.hourglass_bottom;
    } else if (error is ValidationException) {
      errorMessage = error.message;
      errorIcon = Icons.warning;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(errorIcon, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userFuture = ApiService().fetchUser(1);
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserWidget(Map<String, dynamic>? userData) {
    return Center(
      child: Text('Usuario: ${userData?['name']}'),
    );
  }
}
```

---

## 3. Result Pattern (Alternativa a Try-Catch)

### 3.1 Implementar Result

```dart
// lib/models/result.dart
abstract class Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  });

  R map<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  });
}

class Success<T> extends Result<T> {
  final T data;

  Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return success(data);
  }

  @override
  R map<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  }) {
    return onSuccess(data);
  }
}

class Failure<T> extends Result<T> {
  final AppException error;

  Failure(this.error);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return failure(error);
  }

  @override
  R map<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  }) {
    return onFailure(error);
  }
}
```

### 3.2 Usar Result Pattern

```dart
// lib/services/user_repository.dart
class UserRepository {
  Future<Result<User>> getUser(int id) async {
    try {
      final userData = await ApiService().fetchUser(id);
      final user = User.fromJson(userData);
      return Success(user);
    } on AppException catch (e) {
      return Failure(e);
    }
  }
}

// En el widget
class UserScreen extends StatefulWidget {
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<Result<User>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserRepository().getUser(1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<User>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return snapshot.data!.when(
            success: (user) => Center(child: Text('Usuario: ${user.name}')),
            failure: (error) => Center(child: Text('Error: ${error.message}')),
          );
        }

        return const Center(child: Text('Error desconocido'));
      },
    );
  }
}
```

---

## 4. Error Handling con Streams

### 4.1 Manejar Errores en Streams

```dart
// Escuchar stream con manejo de errores
stream.listen(
  (data) {
    // Éxito
    print('Dato: $data');
  },
  onError: (error) {
    // Error
    print('Error: $error');
  },
  onDone: () {
    // Completado
    print('Stream completado');
  },
);

// Usar try-catch con streams
Stream<int> countStream() async* {
  for (int i = 1; i <= 10; i++) {
    if (i == 5) {
      throw Exception('Error en posición 5');
    }
    yield i;
  }
}

void handleStream() {
  countStream().listen(
    (value) => print(value),
    onError: (error) => print('Error del stream: $error'),
  );
}

// Convertir futures a streams con manejo de errores
Future<int> riskyFuture() async {
  throw Exception('Error simulated');
}

void futureToStream() {
  Stream<int> stream = Stream.fromFuture(riskyFuture());
  stream.listen(
    (value) => print('Valor: $value'),
    onError: (error) => print('Error: $error'),
  );
}
```

### 4.2 Recuperación de Errores en Streams

```dart
// Recuperar del error y continuar
Stream<int> resilientStream() async* {
  try {
    for (int i = 1; i <= 10; i++) {
      if (i == 5) throw Exception('Error');
      yield i;
    }
  } catch (e) {
    print('Recuperado del error');
    yield -1; // Valor por defecto
  }
}

// Usar onError en stream
stream
    .handleError((error) {
      print('Error manejado: $error');
      return null;
    })
    .listen((data) {
      if (data != null) print('Dato: $data');
    });

// Usar timeout
stream
    .timeout(Duration(seconds: 5), onTimeout: (sink) {
      sink.addError(TimeoutException('El stream tardó demasiado'));
    })
    .listen(
      (data) => print('Dato: $data'),
      onError: (error) => print('Error o timeout: $error'),
    );
```

---

## 5. Global Error Handler

### 5.1 Configurar Handler Global

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capturar errores no manejados en Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    logError(details.exception, details.stack);
  };

  // Capturar errores asíncronos no manejados
  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error, stack);
    return true; // Prevenir que Flutter cierre la app
  };

  runApp(const MyApp());
}

void logError(Object error, StackTrace? stack) {
  print('Error global: $error');
  print('Stack trace: $stack');
  
  // Enviar a servicio de logging
  // sendToLoggingService(error, stack);
}
```

### 5.2 Widget Error Boundary

```dart
// lib/widgets/error_boundary.dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(Object error, StackTrace stack)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Algo salió mal'),
              const SizedBox(height: 8),
              Text(
                _error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stack = null;
                  });
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return ErrorWidget.builder = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stack = details.stack;
      });
      widget.onError?.call(_error!, _stack!);
      return Container();
    };

    // Retornar widget normal si no hay error
    return widget.child;
  }
}
```

---

## 6. Logging y Monitoreo

### 6.1 Sistema de Logging

```dart
// lib/services/logger_service.dart
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  final List<String> _logs = [];

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [${level.name.toUpperCase()}] $message';

    _logs.add(logEntry);

    if (error != null) {
      _logs.add('Error: $error');
    }

    if (stackTrace != null) {
      _logs.add('Stack: $stackTrace');
    }

    if (kDebugMode) {
      print(logEntry);
      if (error != null) print('Error: $error');
    }

    // Enviar a servidor si es error o fatal
    if (level == LogLevel.error || level == LogLevel.fatal) {
      _sendToServer(message, error, stackTrace);
    }
  }

  void debug(String message) => log(message, level: LogLevel.debug);
  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message, Object? error, StackTrace? stack) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stack);
  void fatal(String message, Object? error, StackTrace? stack) =>
      log(message, level: LogLevel.fatal, error: error, stackTrace: stack);

  List<String> getLogs() => List.from(_logs);

  void clearLogs() => _logs.clear();

  Future<void> _sendToServer(String message, Object? error, StackTrace? stack) async {
    try {
      // Implementar envío al servidor
      print('Enviando error al servidor: $message');
    } catch (e) {
      print('Error al enviar log: $e');
    }
  }
}

// Usar en la app
final logger = LoggerService();

class MyService {
  Future<void> riskyOperation() async {
    try {
      logger.info('Iniciando operación riesgosa');
      // Operación
      logger.info('Operación completada');
    } catch (e, stackTrace) {
      logger.error('Error en operación riesgosa', e, stackTrace);
    }
  }
}
```

### 6.2 Firebase Crashlytics

```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Pasar excepciones no atrapadas a Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

// Registrar errores manualmente
void someFunction() {
  try {
    riskyOperation();
  } catch (e, stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

// Enviar mensajes personalizados
FirebaseCrashlytics.instance.log('Usuario navegó a pantalla de inicio');
```

---

## 7. Estrategias de Recuperación

### 7.1 Retry Logic

```dart
// lib/utils/retry_helper.dart
Future<T> retry<T>({
  required Future<T> Function() operation,
  required int maxAttempts,
  required Duration delay,
  bool Function(Exception)? retryIf,
}) async {
  int attempt = 0;
  
  while (true) {
    try {
      return await operation();
    } on Exception catch (e) {
      attempt++;
      
      if (attempt >= maxAttempts) {
        rethrow;
      }

      if (retryIf != null && !retryIf(e)) {
        rethrow;
      }

      await Future.delayed(delay * attempt); // Exponential backoff
    }
  }
}

// Usar
Future<User> fetchUserWithRetry(int userId) {
  return retry(
    operation: () => ApiService().fetchUser(userId),
    maxAttempts: 3,
    delay: Duration(seconds: 1),
    retryIf: (e) => e is NetworkException || e is TimeoutException,
  );
}
```

### 7.2 Fallback Strategies

```dart
// Intentar múltiples fuentes
Future<User> getUserFromMultipleSources(int userId) async {
  try {
    return await ApiService().fetchUser(userId);
  } catch (e) {
    LoggerService().warning('API falló, intentando cache');
    try {
      return await CacheService().getUser(userId);
    } catch (e) {
      LoggerService().error('Cache falló', e, null);
      throw Exception('No se pudo obtener el usuario');
    }
  }
}

// Circuit Breaker pattern
class CircuitBreaker {
  int _failureCount = 0;
  final int _failureThreshold = 5;
  bool _isOpen = false;
  DateTime? _openTime;
  final Duration _resetTimeout = Duration(minutes: 1);

  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_isOpen) {
      if (DateTime.now().difference(_openTime!) > _resetTimeout) {
        _isOpen = false;
        _failureCount = 0;
      } else {
        throw Exception('Circuit breaker abierto');
      }
    }

    try {
      final result = await operation();
      _failureCount = 0;
      return result;
    } catch (e) {
      _failureCount++;
      if (_failureCount >= _failureThreshold) {
        _isOpen = true;
        _openTime = DateTime.now();
      }
      rethrow;
    }
  }
}
```

---

## 8. Best Practices

### ✅ DO's
- Usar excepciones específicas
- Proporcionar mensajes claros
- Loguear errores
- Mostrar feedback al usuario
- Implementar retry logic
- Usar finally para limpiar recursos
- Tener error boundaries

### ❌ DON'Ts
- Ignorar excepciones (`catch (e) {}`)
- Mensajes técnicos al usuario
- Crashear en case de error
- Perder información del error
- Reintentos infinitos
- Mostrar stack traces al usuario

---

## 9. Checklist de Error Handling

- ✅ Excepciones personalizadas creadas
- ✅ Try-catch en operaciones críticas
- ✅ Manejo de errores de red
- ✅ Timeouts configurados
- ✅ Validación de entrada
- ✅ Mensajes de error al usuario
- ✅ Logging de errores
- ✅ Error boundaries en widgets
- ✅ Retry logic implementado
- ✅ Fallback strategies listas

---

## 10. Ejercicios

### Ejercicio 1: Sistema de Validación
Crear validadores con excepciones personalizadas para:
- Email inválido
- Contraseña débil
- Campo vacío

### Ejercicio 2: API Resiliente
Crear servicio con:
- Retry automático
- Timeouts
- Manejo de errores
- Logging completo

### Ejercicio 3: Error Boundaries
Crear widgets con:
- Error boundary
- Manejo de errores UI
- Recuperación automática

---

Conceptos Relacionados:
- 03_ADVANCED_BUILDERS_STREAMS_FUTURE
- 12_GESTION_ESTADO
- 14_CONSUMO_APIS
- 22_CLEAN_ARCHITECTURE
- EJERCICIOS_17_MANEJO_ERRORES

## Resumen

El manejo de errores es esencial para:
- ✅ Aplicaciones estables
- ✅ Mejor UX
- ✅ Debugging eficiente
- ✅ Confiabilidad
- ✅ Profesionalismo

Usar excepciones personalizadas, try-catch, logging y recovery strategies.
