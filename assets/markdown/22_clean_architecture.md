# Clean Architecture en Flutter: Guía Profesional

## Introducción a Clean Architecture

Clean Architecture es un patrón de diseño que separa la aplicación en capas independientes, facilitando el testing, mantenimiento y escalabilidad.

### Principios

- **Independencia de frameworks**: La lógica no depende de Flutter
- **Testeable**: La lógica de negocio es fácil de probar
- **Separación de responsabilidades**: Cada capa tiene un propósito
- **Fácil mantenimiento**: Cambios localizados
- **Escalable**: Crece sin problemas de arquitectura

---

## 1. Capas de Clean Architecture

```
┌─────────────────────────────────────────┐
│     Presentation (UI & Controllers)     │
├─────────────────────────────────────────┤
│  Domain (Entities, Use Cases)           │
├─────────────────────────────────────────┤
│  Data (Repositories, Data Sources)      │
├─────────────────────────────────────────┤
│  Core (Constants, Utils, Exceptions)    │
└─────────────────────────────────────────┘
```

### Estructura de Carpetas

```
lib/
├── core/
│   ├── constants/
│   ├── exceptions/
│   ├── usecase/
│   ├── params/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   ├── repositories/
│   └── mappers/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── failures/
├── presentation/
│   ├── blocs/
│   ├── pages/
│   ├── widgets/
│   └── providers/
└── main.dart
```

---

## 2. Domain Layer (Núcleo)

### 2.1 Entities

```dart
// lib/domain/entities/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String profileUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode;
}
```

### 2.2 Failures

```dart
// lib/domain/failures/failures.dart
abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
```

### 2.3 Repositories (Abstract)

```dart
// lib/domain/repositories/user_repository.dart
import 'package:mi_app/domain/entities/user.dart';
import 'package:mi_app/domain/failures/failures.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser(int id);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, void>> createUser(User user);
  Future<Either<Failure, void>> updateUser(User user);
  Future<Either<Failure, void>> deleteUser(int id);
}
```

### 2.4 Use Cases

```dart
// lib/core/usecase/usecase.dart
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// lib/domain/usecases/get_user.dart
import 'package:dartz/dartz.dart';
import 'package:mi_app/core/usecase/usecase.dart';
import 'package:mi_app/domain/entities/user.dart';
import 'package:mi_app/domain/failures/failures.dart';
import 'package:mi_app/domain/repositories/user_repository.dart';

class GetUserUseCase implements UseCase<User, int> {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(int params) async {
    return await repository.getUser(params);
  }
}

// lib/domain/usecases/get_all_users.dart
class GetAllUsersUseCase implements UseCase<List<User>, NoParams> {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) async {
    return await repository.getAllUsers();
  }
}

// lib/core/params/no_params.dart
class NoParams {
  const NoParams();
}
```

---

## 3. Data Layer

### 3.1 Models

```dart
// lib/data/models/user_model.dart
import 'package:mi_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required int id,
    required String name,
    required String email,
    required String profileUrl,
  }) : super(
    id: id,
    name: name,
    email: email,
    profileUrl: profileUrl,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileUrl: json['profileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileUrl': profileUrl,
    };
  }
}
```

### 3.2 Data Sources

```dart
// lib/data/datasources/user_remote_data_source.dart
abstract class UserRemoteDataSource {
  Future<UserModel> getUser(int id);
  Future<List<UserModel>> getAllUsers();
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient _httpClient;

  UserRemoteDataSourceImpl(this._httpClient);

  @override
  Future<UserModel> getUser(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('https://api.example.com/users/$id'),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException('Failed to load user');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('https://api.example.com/users'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => UserModel.fromJson(json))
            .toList();
      } else {
        throw ServerException('Failed to load users');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Implementar otros métodos...
}

// lib/data/datasources/user_local_data_source.dart
import 'package:hive/hive.dart';
import 'package:mi_app/data/models/user_model.dart';
abstract class UserLocalDataSource {
  Future<void> cacheUsers(List<UserModel> users);
  Future<UserModel> getCachedUser(int id);
  Future<List<UserModel>> getCachedUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box<UserModel> _userBox;

  UserLocalDataSourceImpl(this._userBox);

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    await _userBox.clear();
    await _userBox.addAll(users);
  }

  @override
  Future<UserModel> getCachedUser(int id) async {
    final user = _userBox.values.firstWhere((u) => u.id == id);
    return user;
  }

  @override
  Future<List<UserModel>> getCachedUsers() async {
    return _userBox.values.toList();
  }
}
```

### 3.3 Repository Implementation

```dart
// lib/data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:mi_app/core/error/exceptions.dart';
import 'package:mi_app/core/network/network_info.dart';
import 'package:mi_app/domain/entities/user.dart';
import 'package:mi_app/data/datasources/user_local_data_source.dart';
import 'package:mi_app/data/datasources/user_remote_data_source.dart';
import 'package:mi_app/domain/failures/failures.dart';
import 'package:mi_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUser(int id) async {
    return _performRequest(
      remoteCall: () => remoteDataSource.getUser(id),
      localCall: () => localDataSource.getCachedUser(id),
    );
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    return _performRequestList(
      remoteCall: () => remoteDataSource.getAllUsers(),
      localCall: () => localDataSource.getCachedUsers(),
    );
  }

  Future<Either<Failure, T>> _performRequest<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteCall();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final result = await localCall();
        return Right(result);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  Future<Either<Failure, List<T>>> _performRequestList<T>({
    required Future<List<T>> Function() remoteCall,
    required Future<List<T>> Function() localCall,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteCall();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final result = await localCall();
        return Right(result);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }
}
```

---

## 4. Presentation Layer

### 4.1 BLoC

```dart
// lib/presentation/blocs/user_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_app/core/params/no_params.dart';
import 'package:mi_app/domain/entities/user.dart';
import 'package:mi_app/domain/usecases/get_all_users.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserUseCase getUserUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;

  UserBloc({
    required this.getUserUseCase,
    required this.getAllUsersUseCase,
  }) : super(const UserInitial()) {
    on<GetUserEvent>(_onGetUser);
    on<GetAllUsersEvent>(_onGetAllUsers);
  }

  Future<void> _onGetUser(GetUserEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final result = await getUserUseCase(event.id);

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onGetAllUsers(
    GetAllUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UsersLoading());

    final result = await getAllUsersUseCase(const NoParams());

    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }
}

// lib/presentation/blocs/user_event.dart
part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserEvent extends UserEvent {
  final int id;

  const GetUserEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetAllUsersEvent extends UserEvent {
  const GetAllUsersEvent();
}

// lib/presentation/blocs/user_state.dart
part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class UsersLoading extends UserState {
  const UsersLoading();
}

class UsersLoaded extends UserState {
  final List<User> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UsersError extends UserState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object> get props => [message];
}
```

### 4.2 UI Pages

```dart
// lib/presentation/pages/users_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_app/presentation/blocs/user_bloc.dart';
class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsersLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              },
            );
          }

          if (state is UsersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(const GetAllUsersEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Sin datos'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<UserBloc>().add(const GetAllUsersEvent());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

---

## 5. Dependency Injection

### 5.1 Setup con GetIt

```yaml
dependencies:
  get_it: ^7.6.0
```

```dart
// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mi_app/core/network/network_info.dart';
import 'package:mi_app/data/datasources/user_local_data_source.dart';
import 'package:mi_app/data/datasources/user_remote_data_source.dart';
import 'package:mi_app/data/repositories/user_repository_impl.dart';
import 'package:mi_app/domain/repositories/user_repository.dart';
import 'package:mi_app/domain/usecases/get_all_users.dart';
import 'package:mi_app/domain/usecases/get_user.dart';
import 'package:mi_app/presentation/blocs/user_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // BLoCs
  getIt.registerSingleton<UserBloc>(
    UserBloc(
      getUserUseCase: getIt(),
      getAllUsersUseCase: getIt(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<GetUserUseCase>(
    GetUserUseCase(getIt()),
  );

  getIt.registerSingleton<GetAllUsersUseCase>(
    GetAllUsersUseCase(getIt()),
  );

  // Repositories
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data Sources
  getIt.registerSingleton<UserRemoteDataSource>(
    UserRemoteDataSourceImpl(getIt()),
  );

  getIt.registerSingleton<UserLocalDataSource>(
    UserLocalDataSourceImpl(getIt()),
  );

  // External
  getIt.registerSingleton<http.Client>(http.Client());
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());
}

// main.dart
void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => getIt<UserBloc>()..add(const GetAllUsersEvent()),
        child: const UsersPage(),
      ),
    );
  }
}
```

---

## 6. Testing

### 6.1 Unit Tests

```dart
// test/domain/usecases/get_user_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mi_app/domain/entities/user.dart';
import 'package:mi_app/domain/usecases/get_user.dart';
void main() {
  group('GetUserUseCase', () {
    late GetUserUseCase useCase;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
      useCase = GetUserUseCase(mockUserRepository);
    });

    const testUser = User(
      id: 1,
      name: 'John',
      email: 'john@example.com',
      profileUrl: '',
    );

    test('should get user from repository', () async {
      when(mockUserRepository.getUser(1))
          .thenAnswer((_) async => const Right(testUser));

      final result = await useCase(1);

      expect(result, const Right(testUser));
      verify(mockUserRepository.getUser(1));
      verifyNoMoreInteractions(mockUserRepository);
    });
  });
}
```

### 6.2 BLoC Tests

```dart
// test/presentation/blocs/user_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mi_app/domain/entities/user.dart';
import 'package:mi_app/presentation/blocs/user_bloc.dart';
void main() {
  group('UserBloc', () {
    late UserBloc userBloc;
    late MockGetUserUseCase mockGetUserUseCase;

    setUp(() {
      mockGetUserUseCase = MockGetUserUseCase();
      userBloc = UserBloc(
        getUserUseCase: mockGetUserUseCase,
        getAllUsersUseCase: MockGetAllUsersUseCase(),
      );
    });

    test('initial state is UserInitial', () {
      expect(userBloc.state, isA<UserInitial>());
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when GetUserEvent is added',
      build: () {
        when(mockGetUserUseCase(1)).thenAnswer(
          (_) async => const Right(testUser),
        );
        return userBloc;
      },
      act: (bloc) => bloc.add(const GetUserEvent(1)),
      expect: () => [
        const UserLoading(),
        const UserLoaded(testUser),
      ],
    );
  });
}
```

---

## 7. Best Practices

✅ **DO's:**
- Mantener capas independientes
- Usar SOLID principles
- Inyectar dependencias
- Manejar errores adecuadamente
- Escribir tests
- Documentar la arquitectura

❌ **DON'Ts:**
- Mezclar capas
- Hacer business logic en UI
- Importar Presentation en Domain
- Olvidar manejar failures
- No testar

---

## 8. Ejercicios

### Ejercicio 1: App de Tareas
Implementar con Clean Architecture

### Ejercicio 2: E-commerce
Crear con múltiples entidades

### Ejercicio 3: Chat App
Implementar con real-time updates

---

Conceptos Relacionados:
- 12_GESTION_ESTADO
- 16_TESTING
- 17_MANEJO_ERRORES
- 20_RIVERPOD_STATE_MANAGEMENT
- EJERCICIOS_22_CLEAN_ARCHITECTURE

## Resumen

Clean Architecture proporciona:
- ✅ Separación clara de responsabilidades
- ✅ Fácil testing
- ✅ Escalabilidad
- ✅ Mantenibilidad
- ✅ Profesionalismo
