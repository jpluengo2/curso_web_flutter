# Organización de Carpetas en Proyectos Flutter

Estructura recomendada para organizar un proyecto Flutter profesional y escalable.

---

## 1. Estructura Básica Recomendada

```
proyecto/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── config/                      # Configuración global
│   │   ├── app_config.dart
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── screens/                     # Pantallas completas
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── widgets/
│   │   │   └── models/
│   │   └── profile/
│   ├── widgets/                     # Componentes reutilizables
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   └── common/
│   ├── models/                      # Modelos de datos (entities)
│   │   ├── user_model.dart
│   │   └── product_model.dart
│   ├── services/                    # Servicios (API, DB, etc)
│   │   ├── api_service.dart
│   │   ├── database_service.dart
│   │   └── auth_service.dart
│   ├── providers/                   # State management
│   │   ├── user_provider.dart
│   │   └── product_provider.dart
│   ├── utils/                       # Funciones auxiliares
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   └── routes/                      # Navegación
│       └── app_router.dart
├── assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── animations/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
└── pubspec.yaml
```

---

## 2. Descripción de Cada Carpeta

### `config/`
Configuración global de la app:
```dart
// config/constants.dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.example.com';
  static const int timeoutDuration = 30;
  static const String appVersion = '1.0.0';
}

// config/theme.dart
ThemeData get lightTheme {
  return ThemeData(
    primarySwatch: Colors.blue,
    // ... más configuración
  );
}
```

### `screens/`
Pantallas completas de la app (una carpeta por pantalla):
```
screens/
├── home/
│   ├── home_screen.dart             # Widget principal
│   ├── widgets/                     # Widgets locales
│   │   ├── home_header.dart
│   │   └── home_list.dart
│   ├── models/                      # Modelos específicos de pantalla
│   │   └── home_item.dart
│   └── providers/                   # Providers de esta pantalla
│       └── home_provider.dart
└── profile/
    ├── profile_screen.dart
    ├── widgets/
    ├── models/
    └── providers/
```

### `widgets/`
Componentes reutilizables en múltiples pantallas:
```
widgets/
├── custom_button.dart              # Botón personalizado
├── custom_card.dart                # Card personalizada
├── custom_text_field.dart          # Campo de texto
├── common/                         # Widgets muy comunes
│   ├── loading_widget.dart
│   ├── error_widget.dart
│   └── empty_state_widget.dart
└── dialogs/                        # Diálogos personalizados
    ├── confirmation_dialog.dart
    └── info_dialog.dart
```

### `models/`
Modelos de datos (entities):
```dart
// models/user_model.dart
class User {
  final String id;
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
```

### `services/`
Lógica de integración con APIs y bases de datos:
```dart
// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/user_model.dart';
class ApiService {
  static const String baseUrl = 'https://api.example.com';
  
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users')); 
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => User.fromJson(json)).toList();
    // Parsear y retornar
  }
}

// services/database_service.dart
import 'package:sqflite/sqflite.dart';
class DatabaseService {
  late final Database _db;
  
  Future<void> init() async {
    _db = await openDatabase('app_database.db');
  }
}
```

### `providers/`
Estado global con Provider, Riverpod, etc:
```dart
// providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/models/user_model.dart';
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User>>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<AsyncValue<User>> {
  UserNotifier() : super(const AsyncValue.loading());
  
  Future<void> fetchUser() async {
    // Lógica
  }
}
```

### `utils/`
Funciones auxiliares y constantes:
```dart
// utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email requerido';
    if (!value!.contains('@')) return 'Email inválido';
    return null;
  }
}

// utils/extensions.dart
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
```

### `routes/`
Navegación y routing:
```dart
// routes/app_router.dart
class AppRouter {
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}
```

---

## 3. Alternativa: Clean Architecture

Para proyectos más grandes:

```
lib/
├── core/
│   ├── errors/
│   ├── usecases/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   ├── repositories/
│   └── sources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── providers/
    └── bloc/
```

---

## 4. Nomibramiento de Archivos

**Convención: snake_case**
```
✅ BIEN:
  home_screen.dart
  user_model.dart
  api_service.dart
  custom_button.dart
  validators.dart

❌ MAL:
  HomeScreen.dart
  UserModel.dart
  ApiService.dart
  CustomButton.dart
  Validators.dart
```

---

## 5. Estructura de Imports

**Organizar imports en orden:**
```dart
// 1. Imports de Dart
import 'dart:async';
import 'dart:convert';

// 2. Imports de Flutter
import 'package:flutter/material.dart';

// 3. Imports de paquetes externos
import 'package:provider/provider.dart';

// 4. Imports locales
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/api_service.dart';
```

---

## 6. Ejemplo Completo de Pantalla

```dart
// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/home/widgets/home_header.dart';
import 'package:myapp/screens/home/widgets/home_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: HomeList(users: userProvider.users),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 7. Archivo pubspec.yaml Bien Organizado

```yaml
name: myapp
description: Mi aplicación Flutter

version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.0
  provider: ^6.0.0
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_linter: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

---

## 8. .gitignore Recomendado

```
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
build/

# Android
android/local.properties
android/.gradle

# iOS
ios/Pods/
ios/Podfile.lock

# IDE
.vscode/
.idea/
*.swp
*.swo
*.iml

# Other
*.log
.env
.DS_Store
```

---

## 9. Buenas Prácticas

✅ **DO's:**
- Mantener carpetas máximo 2 niveles de profundidad
- Un archivo = una clase pública
- Separar responsabilidades claramente
- Nombrar consistentemente
- Documentar carpetas complejas

❌ **DON'Ts:**
- No mezclar modelos con servicios
- No tener archivos sueltos en `lib/`
- No duplicar código entre widgets
- No dejar comentarios obsoletos
- No cambiar estructura a mitad del proyecto
