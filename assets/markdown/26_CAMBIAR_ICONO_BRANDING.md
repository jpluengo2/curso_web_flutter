# Cambiar Icono y Branding de la App

Guía completa para personalizar el icono, nombre, colores y branding de tu app Flutter en todas las plataformas.

---

## 1. Cambiar el Icono de la App

### Opción A: Con flutter_launcher_icons (Recomendado)

**Ventajas:**
- Genera todos los tamaños automáticamente
- Compatible con Android e iOS
- Una sola imagen de origen

**Pasos:**

1. **Preparar imagen:** `1024x1024 px` PNG con fondo transparente
2. **Instalar paquete:**
   ```bash
   flutter pub add flutter_launcher_icons
   ```

3. **Configurar en `pubspec.yaml`:**
   ```yaml
   flutter_launcher_icons:
     android: "launcher_icon"
     ios: true
     image_path: "assets/icon/icon.png"
     adaptive_icon_background: "#ffffff"
     adaptive_icon_foreground: "assets/icon/icon_foreground.png"
   ```

4. **Ejecutar:**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

### Opción B: Manual Android

**Carpetas necesarias:**
```
android/app/src/main/res/
├── mipmap-ldpi/
├── mipmap-mdpi/
├── mipmap-hdpi/
├── mipmap-xhdpi/
├── mipmap-xxhdpi/
└── mipmap-xxxhdpi/
```

**Tamaños requeridos:**
- ldpi: 36x36
- mdpi: 48x48
- hdpi: 72x72
- xhdpi: 96x96
- xxhdpi: 144x144
- xxxhdpi: 192x192

### Opción C: Manual iOS

1. Abrir: `ios/Runner.xcworkspace` en Xcode
2. Navegar a: Runner > Assets > AppIcon
3. Arrastra imágenes en tamaños específicos
4. Xcode muestra los tamaños requeridos

### Opción D: Icono Adaptativo (Android 8+)

Permite fondos de colores dinámicos:

```yaml
flutter_launcher_icons:
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
```

---

## 2. Cambiar el Nombre de la App

### Opción A: Con rename (Automático)

```bash
flutter pub add rename
flutter pub run rename --appname "Mi Nueva App"
flutter pub run rename --bundleId com.example.miapp
```

### Opción B: Manual Android

Archivo: `android/app/build.gradle.kts`
```kotlin
android {
    defaultConfig {
        applicationId = "com.example.miapp"
        // applicationIdSuffix = ".dev" // Para versión dev
    }
}
```

Archivo: `android/app/src/main/AndroidManifest.xml`
```xml
<application android:label="@string/app_name">
```

Archivo: `android/app/src/main/res/values/strings.xml`
```xml
<resources>
    <string name="app_name">Mi Nueva App</string>
</resources>
```

### Opción C: Manual iOS

Archivo: `ios/Runner/Info.plist`
```xml
<key>CFBundleName</key>
<string>Mi Nueva App</string>

<key>CFBundleDisplayName</key>
<string>Mi App</string>
```

Archivo: `ios/Runner.xcodeproj/project.pbxproj`
- Product Name: "Runner" → "Mi App"

---

## 3. Esquema de Colores y Branding

### 3.1 Color Primario Global

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE), // Tu color principal
      brightness: Brightness.light,
    ),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6200EE),
      brightness: Brightness.dark,
    ),
  ),
)
```

### 3.2 Tipografía Custom

```dart
theme: ThemeData(
  fontFamily: 'Roboto', // O tu fuente personalizada
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 16),
  ),
)
```

### 3.3 Colores Personalizados

```dart
class AppColors {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF03DAC6);
  static const error = Color(0xFFCF6679);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
}

// Uso
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
  ),
  onPressed: () {},
  child: const Text('Botón'),
)
```

---

## 4. Splash Screen Personalizado

### Con flutter_native_splash

```bash
flutter pub add flutter_native_splash
```

Configurar en `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#42a5f5"
  image: "assets/splash.png"
  android_12:
    image: "assets/splash_android12.png"
    icon_background_color: "#42a5f5"
```

Ejecutar:
```bash
dart run flutter_native_splash:create
```

---

## 5. Configuración por Sabor (Flavor)

Múltiples versiones de la app (dev, staging, prod):

### Android

Archivo: `android/app/build.gradle.kts`
```kotlin
flavorDimensions += "app"
productFlavors {
    dev {
        dimension = "app"
        applicationIdSuffix = ".dev"
    }
    prod {
        dimension = "app"
    }
}
```

### iOS

Usar schemes en Xcode

### Flutter

Ejecutar con flavor:
```bash
flutter run --flavor dev
flutter run --flavor prod
```

---

## 6. Checklist de Branding

- [ ] Icono de app en todos los tamaños
- [ ] Nombre de app consistente (Android y iOS)
- [ ] Color primario definido
- [ ] Tipografía personalizada
- [ ] Splash screen
- [ ] Bundle ID único
- [ ] Versión de app
- [ ] Build number

---

## 7. Problema: El icono no cambia

**Soluciones:**
1. Borrar carpeta `build/`: `flutter clean`
2. Invalidar cache iOS: `rm -rf ios/Pods ios/Podfile.lock`
3. Reinstalar app: `flutter pub get`
4. Reconstruir: `flutter run`

---

## 8. Recursos Útiles

- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
- [rename package](https://pub.dev/packages/rename)
- [Generador de iconos online](https://www.favicon-generator.org/)
