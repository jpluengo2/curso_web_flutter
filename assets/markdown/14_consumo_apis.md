# Consumo de APIs en Flutter - Guía Completa

## 📚 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Conceptos de APIs](#conceptos-de-apis)
3. [HTTP básico](#http-básico)
4. [Dio - Cliente HTTP avanzado](#dio---cliente-http-avanzado)
5. [Retrofit - Tipado y generado](#retrofit---tipado-y-generado)
6. [Manejo de errores](#manejo-de-errores)
7. [Autenticación](#autenticación)
8. [Interceptores](#interceptores)
9. [Caché y optimización](#caché-y-optimización)
10. [Ejemplos prácticos](#ejemplos-prácticos)
11. [Testing](#testing)
12. [Mejores prácticas](#mejores-prácticas)

---

## Introducción

Una API (Application Programming Interface) permite comunicación entre aplicaciones. En Flutter, necesitamos:
- **Hacer peticiones HTTP** (GET, POST, PUT, DELETE)
- **Manejar respuestas** en JSON
- **Gestionar errores** apropiadamente
- **Autenticar usuario** si es necesario
- **Optimizar rendimiento** con caché

### Métodos HTTP

| Método | Uso | Cuerpo |
|--------|-----|--------|
| **GET** | Obtener datos | No |
| **POST** | Crear datos | Sí |
| **PUT** | Actualizar datos | Sí |
| **PATCH** | Actualizar parcial | Sí |
| **DELETE** | Eliminar datos | No |

---

## Conceptos de APIs

### REST API

Patrón arquitectónico basado en recursos HTTP.

```dart
// Estructura típica de una REST API
GET    /api/users           // Obtener todos
GET    /api/users/123       // Obtener uno
POST   /api/users           // Crear
PUT    /api/users/123       // Actualizar completo
PATCH  /api/users/123       // Actualizar parcial
DELETE /api/users/123       // Eliminar
```

### Status Codes

```dart
// Códigos de respuesta HTTP
200 OK              // Éxito
201 Created         // Recurso creado
204 No Content      // Éxito sin contenido
400 Bad Request     // Solicitud malformada
401 Unauthorized    // No autenticado
403 Forbidden       // No autorizado
404 Not Found       // No existe
500 Server Error    // Error del servidor
503 Unavailable     // Servidor no disponible
```

### Headers

```dart
// Headers comunes
Content-Type: application/json
Authorization: Bearer token
Accept: application/json
User-Agent: Flutter app
```

---

## HTTP Básico

### Usando package:http

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Instalación
// dependencies:
//   http: ^1.1.0

// ===== GET REQUEST =====

// GET simple
Future<void> getSimple() async {
  try {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );

    if (response.statusCode == 200) {
      print('Respuesta: ${response.body}');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Excepción: $e');
  }
}

// GET con parámetros
Future<List<dynamic>> getWithParams(String query) async {
  final uri = Uri.https('jsonplaceholder.typicode.com', '/users', {
    'name': query,
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error: ${response.statusCode}');
  }
}

// GET con headers personalizados
Future<Map<String, dynamic>> getWithHeaders() async {
  final response = await http.get(
    Uri.parse('https://api.example.com/data'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer token123',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error: ${response.statusCode}');
  }
}

// ===== POST REQUEST =====

// POST simple
Future<Map<String, dynamic>> postSimple(String name, String email) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'email': email,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error: ${response.statusCode}');
  }
}

// POST con modelo
class User {
  final String name;
  final String email;
  final String phone;

  User({
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
  );
}

Future<User> createUser(User user) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error creando usuario');
  }
}

// ===== PUT REQUEST =====

Future<User> updateUser(int id, User user) async {
  final response = await http.put(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error actualizando usuario');
  }
}

// ===== DELETE REQUEST =====

Future<void> deleteUser(int id) async {
  final response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Error eliminando usuario');
  }
}

// ===== PATCH REQUEST =====

Future<User> partialUpdate(int id, Map<String, dynamic> updates) async {
  final response = await http.patch(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(updates),
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error actualizando usuario');
  }
}
```

### Cliente HTTP reutilizable

```dart
class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _httpClient = http.Client();

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
    },
  });

  // GET
  Future<T> get<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Error en GET: $e');
    }
  }

  // POST
  Future<T> post<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Error en POST: $e');
    }
  }

  // PUT
  Future<T> put<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Error en PUT: $e');
    }
  }

  // DELETE
  Future<T> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Error en DELETE: $e');
    }
  }

  // Manejar respuesta
  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null as T;
      }

      final json = jsonDecode(response.body);
      return fromJson != null ? fromJson(json) : json as T;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('No autorizado');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Acceso denegado');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Recurso no encontrado');
    } else if (response.statusCode >= 500) {
      throw ServerException('Error del servidor');
    } else {
      throw ApiException('Error: ${response.statusCode}');
    }
  }
}

// Excepciones personalizadas
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

// Uso
final apiClient = ApiClient(baseUrl: 'https://jsonplaceholder.typicode.com');

// GET
final users = await apiClient.get<List>(
  '/users',
  fromJson: (json) => (json as List).map((u) => User.fromJson(u)).toList(),
);

// POST
final newUser = await apiClient.post(
  '/users',
  body: User(name: 'Juan', email: 'juan@example.com', phone: '123456'),
);
```

---

## Dio - Cliente HTTP Avanzado

### Configuración básica

```dart
import 'package:dio/dio.dart';

// Instalación
// dependencies:
//   dio: ^5.3.0

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        sendTimeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptores
    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Enviando: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Respuesta: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // GET
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      return fromJson != null ? fromJson(response.data) : response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE
  Future<T> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return fromJson != null ? fromJson(response.data) : response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Descargar archivo
  Future<void> downloadFile(String url, String savePath) async {
    try {
      await _dio.download(url, savePath);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Subir archivo
  Future<T> uploadFile<T>(
    String path,
    String filePath, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(path, data: formData);
      return fromJson != null ? fromJson(response.data) : response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Manejar errores
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.badResponse:
        return ApiException('Error: ${error.response?.statusCode}');
      case DioExceptionType.connectionTimeout:
        return ApiException('Timeout de conexión');
      case DioExceptionType.receiveTimeout:
        return ApiException('Timeout de recepción');
      case DioExceptionType.sendTimeout:
        return ApiException('Timeout de envío');
      case DioExceptionType.badCertificate:
        return ApiException('Certificado inválido');
      case DioExceptionType.connectionError:
        return ApiException('Error de conexión');
      case DioExceptionType.unknown:
        return ApiException('Error desconocido: ${error.message}');
      default:
        return ApiException('Error: ${error.message}');
    }
  }
}

// Uso
final dioClient = DioClient();

final users = await dioClient.get<List>(
  '/users',
  fromJson: (json) => json,
);

final newUser = await dioClient.post(
  '/users',
  data: {'name': 'Juan', 'email': 'juan@example.com'},
);
```

### Monitorear progreso de descarga

```dart
Future<void> downloadWithProgress(String url, String savePath) async {
  await _dio.download(
    url,
    savePath,
    onReceiveProgress: (count, total) {
      final progress = (count / total * 100).toStringAsFixed(0);
      print('Descargado: $progress%');
    },
  );
}

// En Flutter UI
class DownloadScreen extends StatefulWidget {
  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  double _downloadProgress = 0;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Descargar')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloading)
              Column(
                children: [
                  CircularProgressIndicator(value: _downloadProgress),
                  SizedBox(height: 16),
                  Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isDownloading
                ? null
                : () async {
                  setState(() => _isDownloading = true);
                  
                  try {
                    await dioClient.downloadWithProgress(
                      'https://example.com/largefile.zip',
                      '/path/to/save',
                    );
                  } catch (e) {
                    print('Error: $e');
                  } finally {
                    setState(() => _isDownloading = false);
                  }
                },
              child: Text('Descargar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Retrofit - Tipado y Generado

### Configuración

```dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

// Instalación
// dependencies:
//   retrofit: ^4.1.0
//   dio: ^5.3.0
// dev_dependencies:
//   retrofit_generator: ^8.0.0
//   build_runner: ^2.4.0

part 'api_client.g.dart';

// Definir API con decoradores
@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // GET un usuario
  @GET('/users/{id}')
  Future<User> getUserById(@Path('id') int id);

  // GET lista de usuarios
  @GET('/users')
  Future<List<User>> getUsers();

  // GET con query parameters
  @GET('/users')
  Future<List<User>> searchUsers(
    @Query('name') String name,
    @Query('email') String email,
  );

  // POST crear usuario
  @POST('/users')
  Future<User> createUser(@Body() User user);

  // PUT actualizar usuario
  @PUT('/users/{id}')
  Future<User> updateUser(@Path('id') int id, @Body() User user);

  // DELETE eliminar usuario
  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') int id);

  // PATCH actualización parcial
  @PATCH('/users/{id}')
  Future<User> partialUpdate(@Path('id') int id, @Body() Map<String, dynamic> updates);

  // Descargar archivo
  @GET('/files/{fileName}')
  Future<List<int>> downloadFile(@Path('fileName') String fileName);

  // Subir archivo
  @MultiPart()
  @POST('/upload')
  Future<UploadResponse> uploadFile(
    @Part(name: 'file') List<int> fileBytes,
    @Part(name: 'name') String fileName,
  );

  // Headers personalizados
  @GET('/data')
  Future<Map<String, dynamic>> getWithCustomHeaders(
    @Header('Authorization') String authorization,
    @Header('X-Custom-Header') String customHeader,
  );
}

// Modelos
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

part 'upload_response.g.dart';

@JsonSerializable()

@JsonSerializable()
class UploadResponse {
  final bool success;
  final String message;
  final String fileUrl;

  UploadResponse({
    required this.success,
    required this.message,
    required this.fileUrl,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) => _$UploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);
}

// Generar código
// flutter pub run build_runner build

// Uso
final dio = Dio();
final apiClient = ApiClient(dio);

// Llamar métodos
final user = await apiClient.getUserById(1);
final users = await apiClient.getUsers();
final newUser = await apiClient.createUser(
  User(id: 0, name: 'Juan', email: 'juan@example.com', phone: '123456'),
);
```

### Repository con Retrofit

```dart
class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<List<User>> getUsers() async {
    try {
      return await _apiClient.getUsers();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserById(int id) async {
    try {
      return await _apiClient.getUserById(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> createUser(User user) async {
    try {
      return await _apiClient.createUser(user);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateUser(int id, User user) async {
    try {
      return await _apiClient.updateUser(id, user);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      return await _apiClient.deleteUser(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.badResponse:
        return Exception('Error: ${error.response?.statusCode}');
      case DioExceptionType.connectionTimeout:
        return Exception('Timeout de conexión');
      default:
        return Exception('Error: ${error.message}');
    }
  }
}
```

---

## Manejo de Errores

### Tipos de errores

```dart
abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  final int statusCode;
  ServerException(String message, {required this.statusCode}) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ParseException extends ApiException {
  ParseException(String message) : super(message);
}

// Manejar errores de Dio
Exception handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutException('Timeout de conexión');

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode ?? 0;
      final message = error.response?.data['message'] ?? 'Error desconocido';
      
      if (statusCode == 401) {
        return UnauthorizedException('No autenticado');
      } else if (statusCode == 403) {
        return UnauthorizedException('No autorizado');
      } else if (statusCode >= 500) {
        return ServerException(message, statusCode: statusCode);
      } else {
        return ServerException(message, statusCode: statusCode);
      }

    case DioExceptionType.badCertificate:
      return NetworkException('Certificado inválido');

    case DioExceptionType.connectionError:
      return NetworkException('Sin conexión a internet');

    default:
      return NetworkException(error.message ?? 'Error desconocido');
  }
}

// Uso en UI
class ErrorHandler {
  static String getErrorMessage(Exception error) {
    if (error is TimeoutException) {
      return 'La solicitud tardó demasiado. Intenta de nuevo.';
    } else if (error is NetworkException) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (error is UnauthorizedException) {
      return 'No tienes permiso para acceder.';
    } else if (error is ServerException) {
      return 'Error del servidor: ${error.message}';
    } else {
      return 'Error: ${error.toString()}';
    }
  }

  static void showErrorSnackBar(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

## Autenticación

### Token Bearer

```dart
class AuthInterceptor extends Interceptor {
  final String Function() getToken;

  AuthInterceptor({required this.getToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// Agregar interceptor a Dio
final dio = Dio();
dio.interceptors.add(
  AuthInterceptor(getToken: () => 'token_from_storage'),
);

// Servicio de autenticación
class AuthService {
  final Dio _dio;
  String? _token;

  AuthService(this._dio);

  String? get token => _token;

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'https://api.example.com/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      _token = response.data['token'];
      // Guardar token
      await SecureStorageHelper.saveToken(_token!);
    } on DioException catch (e) {
      throw UnauthorizedException('Error en login: ${e.message}');
    }
  }

  Future<void> logout() async {
    _token = null;
    await SecureStorageHelper.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    _token = await SecureStorageHelper.getToken();
    return _token != null && _token!.isNotEmpty;
  }

  Future<void> refreshToken() async {
    try {
      final response = await _dio.post(
        'https://api.example.com/refresh-token',
        options: Options(
          headers: {'Authorization': 'Bearer $_token'},
        ),
      );

      _token = response.data['token'];
      await SecureStorageHelper.saveToken(_token!);
    } on DioException {
      await logout();
      throw UnauthorizedException('Token expirado');
    }
  }
}

// Interceptor para renovar token automáticamente
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthService authService;

  TokenRefreshInterceptor({required this.dio, required this.authService});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // 1. Refrescar el token
        await authService.refreshToken();

        // 2. Clonar la petición original con el nuevo token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${authService.token}';

        // 3. Reintentar la petición
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        // Si el refresco falla, propagar el error
        return handler.next(e);
      } catch (e) {
        return handler.next(err); // Propagar error original si algo más falla
      }
    } else {
      handler.next(err);
    }
  }
}
```

### Login y registro

```dart
class AuthRepository {
  final ApiClient _apiClient;
  final AuthService _authService;

  AuthRepository(this._apiClient, this._authService);

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final token = response['token'];
      await SecureStorageHelper.saveToken(token);
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } catch (e) {
      print('Error en logout: $e');
    }
    await _authService.logout();
  }

  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }
}

// Uso en Flutter
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  AuthRepository? _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                ? null
                : () async {
                  setState(() => _isLoading = true);
                  try {
                    await _authRepository?.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                    Navigator.of(context).pushReplacementNamed('/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
              child: _isLoading
                ? CircularProgressIndicator()
                : Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Interceptores

### Logging

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('╔ Request ╔══════════════════════════════════════════════════════════');
    print('║ ${options.method} ${options.path}');
    print('║ Headers: ${options.headers}');
    if (options.data != null) {
      print('║ Body: ${options.data}');
    }
    print('╚══════════════════════════════════════════════════════════════════════════════');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('╔ Response ╔═════════════════════════════════════════════════════════');
    print('║ ${response.statusCode}');
    print('║ Data: ${response.data}');
    print('╚══════════════════════════════════════════════════════════════════════════════');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('╔ Error ╔═══════════════════════════════════════════════════════════');
    print('║ ${err.message}');
    print('║ Response: ${err.response?.data}');
    print('╚══════════════════════════════════════════════════════════════════════════════');
    handler.next(err);
  }
}
```

### Rate limiting

```dart
class RateLimitInterceptor extends Interceptor {
  final int requestsPerMinute;
  final List<DateTime> _requestTimes = [];

  RateLimitInterceptor({this.requestsPerMinute = 60});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final now = DateTime.now();
    
    // Limpiar solicitudes antiguas (más de 1 minuto)
    _requestTimes.removeWhere(
      (time) => now.difference(time).inMinutes > 1,
    );

    if (_requestTimes.length >= requestsPerMinute) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Rate limit alcanzado',
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }

    _requestTimes.add(now);
    handler.next(options);
  }
}
```

### Cache

```dart
class CacheInterceptor extends Interceptor {
  final Map<String, CachedResponse> _cache = {};
  final Duration cacheDuration;

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toLowerCase() == 'get') {
      final cachedResponse = _cache[options.path];
      
      if (cachedResponse != null &&
          DateTime.now().difference(cachedResponse.time).compareTo(cacheDuration) < 0) {
        print('Usando respuesta en caché para ${options.path}');
        handler.resolve(cachedResponse.response);
        return;
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toLowerCase() == 'get') {
      _cache[response.requestOptions.path] = CachedResponse(
        response: response,
        time: DateTime.now(),
      );
    }
    handler.next(response);
  }
}

class CachedResponse {
  final Response response;
  final DateTime time;

  CachedResponse({required this.response, required this.time});
}
```

---

## Caché y Optimización

### Pagination

```dart
class PaginationHelper {
  int currentPage = 1;
  int pageSize = 20;
  int totalPages = 0;
  bool hasMorePages = true;

  void reset() {
    currentPage = 1;
    totalPages = 0;
    hasMorePages = true;
  }

  void nextPage() {
    if (hasMorePages) {
      currentPage++;
    }
  }

  Map<String, dynamic> getQueryParams() {
    return {
      'page': currentPage,
      'limit': pageSize,
    };
  }

  void updateFromResponse(Map<String, dynamic> response) {
    totalPages = response['totalPages'] ?? 0;
    hasMorePages = currentPage < totalPages;
  }
}

// Uso
class PaginatedListScreen extends StatefulWidget {
  @override
  State<PaginatedListScreen> createState() => _PaginatedListScreenState();
}

class _PaginatedListScreenState extends State<PaginatedListScreen> {
  final PaginationHelper _pagination = PaginationHelper();
  final ScrollController _scrollController = ScrollController();
  List<User> _users = [];
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_pagination.hasMorePages) {
        _pagination.nextPage();
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(
        '/users',
        queryParameters: _pagination.getQueryParams(),
      );
      
      final newUsers = (response['data'] as List)
        .map((u) => User.fromJson(u))
        .toList();
      
      _pagination.updateFromResponse(response);
      
      setState(() {
        _users.addAll(newUsers);
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _users.length + (_pagination.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return Center(child: CircularProgressIndicator());
          }
          
          final user = _users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## Ejemplos Prácticos

### Aplicación de películas

```dart
class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      rating: (json['vote_average'] as num).toDouble(),
    );
  }
}

class MovieRepository {
  final DioClient _dioClient;
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'YOUR_API_KEY';

  MovieRepository(this._dioClient);

  Future<List<Movie>> getPopularMovies(int page) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/movie/popular',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
        },
      );

      final movies = (response['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();

      return movies;
    } catch (e) {
      throw Exception('Error obteniendo películas: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/search/movie',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
        },
      );

      final movies = (response['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();

      return movies;
    } catch (e) {
      throw Exception('Error buscando películas: $e');
    }
  }
}

class MoviesScreen extends StatefulWidget {
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late MovieRepository _repository;
  late Future<List<Movie>> _moviesFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = MovieRepository(DioClient());
    _moviesFuture = _repository.getPopularMovies(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Películas')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  if (query.isEmpty) {
                    _moviesFuture = _repository.getPopularMovies(1);
                  } else {
                    _moviesFuture = _repository.searchMovies(query);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final movies = snapshot.data ?? [];

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl:
                                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Rating: ${movie.rating}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Testing

### Testear llamadas API

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock del cliente HTTP
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('API Tests', () {
    late MockHttpClient mockHttpClient;
    late ApiClient apiClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiClient = ApiClient(mockHttpClient);
    });

    test('getUsers devuelve lista de usuarios', () async {
      final mockResponse = '''
        [
          {"id": 1, "name": "Juan", "email": "juan@example.com"},
          {"id": 2, "name": "María", "email": "maria@example.com"}
        ]
      ''';

      when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(mockResponse, 200));

      final users = await apiClient.getUsers();

      expect(users, isA<List<User>>());
      expect(users.length, 2);
      expect(users[0].name, 'Juan');
    });

    test('createUser crea un nuevo usuario', () async {
      final mockResponse = '''
        {"id": 3, "name": "Pedro", "email": "pedro@example.com"}
      ''';

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockResponse, 201));

      final newUser = User(
        id: 0,
        name: 'Pedro',
        email: 'pedro@example.com',
        phone: '123456',
      );

      final createdUser = await apiClient.createUser(newUser);

      expect(createdUser.name, 'Pedro');
      expect(createdUser.id, 3);
    });

    test('getUsers lanza excepción en error', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => apiClient.getUsers(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

---

## Mejores Prácticas

### 1. Crear separación de capas

```dart
// ✅ Bien
// data/
//   datasource/
//     - remote_data_source.dart
//   repository/
//     - user_repository.dart
// domain/
//   entity/
//     - user.dart
//   repository/
//     - user_repository.dart
// presentation/
//   screens/
//     - user_screen.dart

// ❌ Evitar
// Mezclar lógica API con UI en widgets
```

### 2. Usar constants para URLs

```dart
// ✅ Bien
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const String usersEndpoint = '/users';
  static const String postsEndpoint = '/posts';
}

// ❌ Evitar
final response = await dio.get('https://api.example.com/users');
```

### 3. Manejar timeout apropiadamente

```dart
// ✅ Bien
final dio = Dio(
  BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ),
);

// ❌ Evitar
final dio = Dio(); // Timeout por defecto muy largo
```

### 4. Encriptar tokens

```dart
// ✅ Bien
await SecureStorageHelper.saveToken(token);

// ❌ Evitar
await PreferencesHelper.saveString('token', token);
```

### 5. Usar Repository pattern

```dart
// ✅ Bien
class UserRepository {
  final ApiClient _apiClient;
  UserRepository(this._apiClient);
  Future<List<User>> getUsers() async { ... }
}

// ❌ Evitar
class UserScreen extends State {
  void initState() {
    ApiClient().getUsers(); // Acceso directo desde UI
  }
}
```

### 6. Implementar retry logic

```dart
// ✅ Bien
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxAttempts = 3,
}) async {
  for (int i = 0; i < maxAttempts; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == maxAttempts - 1) rethrow;
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }
  throw Exception('Max retries exceeded');
}
```

### 7. Validar certificados SSL en producción

```dart
// ✅ Bien
final dio = Dio(
  BaseOptions(
    validateStatus: (status) => status != null && status < 500,
  ),
);

// Crear cliente HTTP personalizado
class MyHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (cert, host, port) {
      return host == 'api.example.com'; // Solo confiar en dominio específico
    };
    // ...
  }
}
```

### 8. Logging y debugging

```dart
// ✅ Bien
final dio = Dio();
if (kDebugMode) {
  dio.interceptors.add(LoggingInterceptor());
}

// ❌ Evitar
print('Enviando solicitud...'); // Prints desorganizados
```

---

## Checklist API

- ✅ Usar client HTTP apropiado (http, Dio, Retrofit)
- ✅ Implementar manejo de errores robusto
- ✅ Usar Repository pattern
- ✅ Autenticar peticiones si es necesario
- ✅ Encriptar tokens sensibles
- ✅ Implementar timeout apropiado
- ✅ Cachear respuestas cuando sea posible
- ✅ Implementar retry logic
- ✅ Loguear peticiones en debug
- ✅ Validar certificados SSL
- ✅ Testear API calls
- ✅ Documentar endpoints

---

Conceptos Relacionados:
- 03_ADVANCED_BUILDERS_STREAMS_FUTURE
- 12_GESTION_ESTADO
- 13_PERSISTENCIA_DATOS
- 15_FIREBASE
- EJERCICIOS_14_CONSUMO_APIS

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio/Avanzado**
