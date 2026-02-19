# Paquetes Populares de pub.dev - Guía Completa

Guía completa de paquetes más usados en proyectos Flutter profesionales, comparativas y casos de uso.

---

## 1. State Management

### Comparativa de Paquetes

| Paquete | Complejidad | Curva Aprendizaje | Casos de Uso | Popularidad |
|---------|-----------|-----------------|------|---------|
| **Provider** | ⭐⭐ | Fácil | Apps pequeñas-medianas | ⭐⭐⭐⭐⭐ |
| **Riverpod** | ⭐⭐⭐ | Media | Proyectos escalables | ⭐⭐⭐⭐⭐ |
| **Bloc/Cubit** | ⭐⭐⭐⭐ | Difícil | Apps grandes | ⭐⭐⭐⭐ |
| **GetX** | ⭐⭐ | Muy fácil | Todo integrado | ⭐⭐⭐⭐ |
| **MobX** | ⭐⭐⭐ | Media | Reactividad | ⭐⭐⭐ |

### Instalación

```bash
# Provider - Recomendado para empezar
flutter pub add provider

# Riverpod - Para proyectos más grandes
flutter pub add flutter_riverpod

# Bloc - Para arquitectura empresarial
flutter pub add flutter_bloc

# GetX - Todo integrado (routing + state + locales)
flutter pub add get

# MobX - State management reactivo
flutter pub add mobx flutter_mobx
```

### Ejemplo de Uso: Provider

```dart
// Crear provider
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
}

// Usar en widget
Consumer<CounterProvider>(
  builder: (context, counter, _) {
    return Text('Contador: ${counter.count}');
  },
)
```

---

## 2. Networking y APIs

### Comparativa

| Paquete | Características | Complejidad | Casos de Uso |
|---------|---|---|---|
| **http** | Básico, poco código | ⭐ | Requests simples |
| **dio** | Interceptores, timeouts | ⭐⭐ | APIs con lógica |
| **retrofit** | Decoradores, tipos | ⭐⭐⭐ | APIs tipadas |
| **chopper** | Generador de código | ⭐⭐⭐ | Seguridad de tipos |

### Instalación y Uso

```bash
flutter pub add dio
flutter pub add http
flutter pub add retrofit
```

#### Ejemplo con Dio
```dart
final dio = Dio()
  ..options.connectTimeout = const Duration(seconds: 10)
  ..interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    },
  ));

final response = await dio.get('/api/users');
```

---

## 3. Base de Datos Local

### Comparativa

| Paquete | Velocidad | Tipo | Cifrado | Ideal Para |
|---------|---|---|---|---|
| **SQLite (sqflite)** | ⭐⭐⭐⭐ | SQL relacional | Opcional | Datos complejos |
| **Hive** | ⭐⭐⭐⭐⭐ | NoSQL key-value | ✅ | Caché rápido |
| **isar** | ⭐⭐⭐⭐⭐ | NoSQL embebido | ✅ | Rendimiento |
| **Moor** | ⭐⭐⭐ | SQL tipado | ❌ | Seguridad de tipos |
| **Realm** | ⭐⭐⭐⭐ | Objeto | ✅ | Objetos complejos |

### Instalación

```bash
# SQLite
flutter pub add sqflite

# Hive - Muy rápido
flutter pub add hive hive_flutter

# isar - Mejor en móvil
flutter pub add isar isar_flutter_libs

# Moor - SQL con tipos
flutter pub add moor_flutter
```

#### Comparativa de Velocidad (insertar 10,000 registros)
- Hive: ~50ms
- isar: ~80ms
- Moor: ~150ms
- SQLite: ~200ms

---

## 4. Firebase

### Servicios Disponibles

```bash
# Core
flutter pub add firebase_core

# Autenticación
flutter pub add firebase_auth

# Base de datos en tiempo real
flutter pub add firebase_database

# Firestore (NoSQL)
flutter pub add cloud_firestore

# Almacenamiento
flutter pub add firebase_storage

# Notificaciones push
flutter pub add firebase_messaging

# Analytics
flutter pub add firebase_analytics

# Crash reporting
flutter pub add firebase_crashlytics

# Remote Config
flutter pub add firebase_remote_config
```

---

## 5. UI y Diseño

### Iconos y Fuentes

```bash
# Google Fonts
flutter pub add google_fonts

# Material Icons extendido
flutter pub add material_design_icons_flutter

# Lottie animations
flutter pub add lottie

# SVG support
flutter pub add flutter_svg
```

### Imágenes

```bash
# Caché de imágenes
flutter pub add cached_network_image

# Image picker
flutter pub add image_picker

# Image editor
flutter pub add photo_editor

# Galería
flutter pub add gallery_saver
```

### Componentes Avanzados

```bash
# Gráficos
flutter pub add fl_chart

# Mapas
flutter pub add google_maps_flutter

# Video player
flutter pub add video_player

# PDF
flutter pub add pdf
flutter pub add printing
```

---

## 6. Validación y Serialización

### Instalación

```bash
# Validadores
flutter pub add form_builder_validators

# JSON serialization
flutter pub add json_serializable
flutter pub add json_annotation

# Freezed para datos inmutables
flutter pub add freezed_annotation
flutter pub add freezed

# Equatable para comparación
flutter pub add equatable
```

#### Ejemplo con Freezed
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}
```

---

## 7. Testing

### Instalación

```bash
# Unit tests
flutter pub add test

# Mocking
flutter pub add mockito
flutter pub add mocktail

# Bloc testing
flutter pub add bloc_test

# State notifier testing
flutter pub add state_notifier
```

---

## 8. Utilidades

### Información del Dispositivo

```bash
flutter pub add device_info_plus
flutter pub add package_info_plus
flutter pub add connectivity_plus
```

### Ubicación

```bash
flutter pub add geolocator
flutter pub add location
```

### Cámara

```bash
flutter pub add camera
flutter pub add image_picker
```

### Notificaciones Locales

```bash
flutter pub add flutter_local_notifications
flutter pub add timezone
```

### Compartir y URLs

```bash
flutter pub add share_plus
flutter pub add url_launcher
flutter pub add uni_links
```

### Almacenamiento Seguro

```bash
flutter pub add flutter_secure_storage
flutter pub add flutter_keychain
```

---

## 9. Desarrollo y Debugging

```bash
# Logs bonitos
flutter pub add logger

# DevTools enhanced
flutter pub add devtools

# App settings
flutter pub add shared_preferences

# Environment variables
flutter pub add flutter_dotenv

# Sentry para crash reporting
flutter pub add sentry_flutter
```

---

## 10. Paquetes "Todo en Uno"

### GetX

```bash
flutter pub add get

# Proporciona:
# - State management (GetxController)
# - Routing (Get.to(), Get.toNamed())
# - Internationalization (GetMaterialApp)
# - Locales
# - Dialogs y Snackbars
```

---

## 11. Instalación Múltiple (Proyecto Nuevo)

```bash
flutter pub add \
  provider \
  dio \
  sqflite \
  firebase_core \
  firebase_auth \
  google_fonts \
  logger \
  json_serializable
```

---

## 12. Cómo Elegir un Paquete

1. **Verificar downloads**: Popular = mantenido
2. **Revisar pub.dev**: Puntuación, comentarios
3. **Buscar documentación**: Ejemplo en GitHub
4. **Probar en pequeño**: Test antes de integración
5. **Considerar alternativas**: Nunca única opción

---

## 13. Recursos

- **Web:** https://pub.dev
- **Flutter Awesome:** https://github.com/Solido/awesome-flutter
- **Buscador:** `flutter pub search [nombre]`
- **Versionado:** Usar `pubspec.lock` para estabilidad
