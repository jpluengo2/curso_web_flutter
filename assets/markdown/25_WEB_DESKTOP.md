# Flutter Web y Desktop: Guía Completa

## Introducción a Flutter Multi-Platform

Flutter permite crear aplicaciones para múltiples plataformas desde un único código base:

- 📱 Mobile (iOS, Android)
- 🌐 Web (Chrome, Firefox, Safari)
- 🖥️ Desktop (Windows, macOS, Linux)

### Ventajas

- ✅ Un código para todas las plataformas
- ✅ Misma lógica de negocio
- ✅ UI adaptativa
- ✅ Performance nativo

---

## 1. Flutter Web

### 1.1 Setup Web

```bash
# Habilitar web
flutter config --enable-web

# Crear proyecto web
flutter create --platforms web mi_app_web

# O agregar web a proyecto existente
flutter create --platforms web .
```

### 1.2 Ejecutar en Web

```bash
# Ejecutar en navegador
flutter run -d chrome

# Ejecutar en Firefox
flutter run -d firefox

# Build para producción
flutter build web

# Build optimizado
flutter build web --release --csp
```

### 1.3 Estructura Web

```
web/
├── index.html          # Página principal
├── favicon.png         # Icono
├── manifest.json       # PWA manifest
└── icons/             # Iconos PWA

build/web/
├── main.dart.js       # Código compilado
├── index.html         # HTML generado
└── assets/            # Recursos
```

### 1.4 Configurar index.html

```html
<!-- web/index.html -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mi App Flutter Web</title>
  <link rel="manifest" href="manifest.json">
  
  <!-- PWA Support -->
  <meta name="theme-color" content="#2196F3">
  <link rel="icon" type="image/png" href="favicon.png">
  
  <!-- Estilos CSS personalizados -->
  <style>
    body {
      margin: 0;
      padding: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto;
    }
    
    #loading {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      background: #f5f5f5;
    }
  </style>
</head>
<body>
  <div id="loading">
    <div style="text-align: center;">
      <div style="width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid #2196F3; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
      <p>Cargando aplicación...</p>
    </div>
  </div>
  
  <script>
    var serviceWorkerVersion = null;
    var scriptLoaded = false;
    function loadMainDartJs() {
      if (scriptLoaded) {
        return;
      }
      scriptLoaded = true;
      var scriptTag = document.createElement('script');
      scriptTag.src = 'main.dart.js';
      scriptTag.type = 'application/javascript';
      document.body.append(scriptTag);
    }

    if ('serviceWorker' in navigator) {
      window.addEventListener('load', function () {
        navigator.serviceWorker.register('flutter_service_worker.js')
          .then(function (reg) {
            console.log('Service Worker registered');
          });
      });
    }
    loadMainDartJs();
  </script>
  
  <style>
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</body>
</html>
```

### 1.5 Configurar PWA

```json
{
  "name": "Mi App Flutter",
  "short_name": "Mi App",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196F3",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

### 1.6 Responsive Design para Web

```dart
class ResponsiveWebApp extends StatelessWidget {
  const ResponsiveWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Web App'),
      ),
      body: isMobile
          ? _buildMobileLayout()
          : isTablet
              ? _buildTabletLayout()
              : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      children: [
        // Layout móvil
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(color: Colors.grey[200]),
        ),
        Expanded(
          flex: 2,
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
          selectedIndex: 0,
          onDestinationSelected: (int index) {},
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
```

### 1.7 URL y Navegación Web

```dart
import 'package:url_launcher/url_launcher.dart';

class WebNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => launchUrl(Uri.parse('https://example.com')),
          child: const Text('Abrir enlace externo'),
        ),
        ElevatedButton(
          onPressed: () => _navigateToDeepLink('/profile/123'),
          child: const Text('Deep link interno'),
        ),
      ],
    );
  }

  void _navigateToDeepLink(String route) {
    // Implementar navegación por URL
    // Usar go_router o similar
  }
}
```

---

## 2. Flutter Desktop

### 2.1 Setup Desktop (Windows)

```bash
# Habilitar Windows
flutter config --enable-windows

# Crear proyecto con Windows
flutter create --platforms windows mi_app_desktop

# Ejecutar en Windows
flutter run -d windows

# Build para distribución
flutter build windows --release
```

### 2.2 Setup Desktop (macOS)

```bash
# Habilitar macOS
flutter config --enable-macos

# Crear proyecto con macOS
flutter create --platforms macos mi_app_desktop

# Ejecutar en macOS
flutter run -d macos

# Build para App Store
flutter build macos --release
```

### 2.3 Setup Desktop (Linux)

```bash
# Habilitar Linux
flutter config --enable-linux

# Crear proyecto con Linux
flutter create --platforms linux mi_app_desktop

# Ejecutar en Linux
flutter run -d linux

# Build para distribución
flutter build linux --release
```

### 2.4 Interfaz Desktop Nativa

```dart
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar ventana
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(400, 300),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Cerrar la aplicación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );

    if (isPreventClose ?? false) {
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Desktop App')),
        body: const Center(child: Text('Hola Desktop')),
      ),
    );
  }
}
```

### 2.5 Menú de Sistema (Desktop)

```dart
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';

void setupTrayManager() async {
  await trayManager.setIcon('assets/icon.png');
  
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'show',
        label: 'Mostrar',
      ),
      MenuItem(
        key: 'hide',
        label: 'Ocultar',
      ),
      MenuItemDivider(),
      MenuItem(
        key: 'exit',
        label: 'Salir',
      ),
    ],
  );
  
  await trayManager.setContextMenu(menu);
}

class TrayListener extends TrayListener {
  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'exit') {
      exit(0);
    }
  }
}
```

---

## 3. Características Específicas de Plataforma

### 3.1 File Access

```dart
import 'dart:io'; // Nota: dart:io no está disponible en web.
import 'package:file_picker/file_picker.dart';

class FileAccessService {
  // Seleccionar archivo
  Future<String?> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // En web, result.files.single.path es null. Usa result.files.single.bytes.
      return result.files.single.path;
    }
    return null;
  }

  // Guardar archivo
  Future<void> saveFile(String content) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final file = File('$selectedDirectory/output.txt');
      await file.writeAsString(content);
    }
  }
}
```

### 3.2 Keyboard Shortcuts

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts extends StatefulWidget {
  @override
  State<KeyboardShortcuts> createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.control) &&
            event.isKeyPressed(LogicalKeyboardKey.keyS)) {
          print('Ctrl+S presionado');
          // Guardar
        }

        if (event.isKeyPressed(LogicalKeyboardKey.control) &&
            event.isKeyPressed(LogicalKeyboardKey.keyN)) {
          print('Ctrl+N presionado');
          // Nuevo
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Keyboard Shortcuts')),
        body: const Center(child: Text('Presiona Ctrl+S o Ctrl+N')),
      ),
    );
  }
}
```

### 3.3 Share Extension

```dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Share.share(
          'Echa un vistazo a mi app: https://example.com',
          subject: 'Mi App Flutter',
        );
      },
      child: const Text('Compartir'),
    );
  }
}
```

---

## 4. Compilación y Distribución

### 4.1 Build Web

```bash
# Build para producción
flutter build web --release

# Build con optimización
flutter build web --release --csp

# Servir localmente
cd build/web
python -m http.server 8000
```

### 4.2 Deploy Web (Firebase Hosting)

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar proyecto
firebase init hosting

# Deploy
flutter build web --release
firebase deploy
```

### 4.3 Build Windows

```bash
# Build ejecutable
flutter build windows --release

# Ubicación
build/windows/runner/Release/

# Crear installer (MSIX)
flutter pub add msix
flutter pub run msix:create
```

### 4.4 Build macOS

```bash
# Build app
flutter build macos --release

# Ubicación
build/macos/Build/Products/Release/

# Crear DMG
hdiutil create -volname "Mi App" -srcfolder build/macos/Build/Products/Release/mi_app.app -ov -format UDZO MiApp.dmg
```

### 4.5 Build Linux

```bash
# Build ejecutable
flutter build linux --release

# Ubicación
build/linux/x64/release/bundle/

# Crear AppImage (opcional)
flutter pub add appimage
flutter pub run appimage:build_appimage
```

---

## 5. Testing para Desktop/Web

### 5.1 Integration Tests Web

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Web app navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });
}

// Ejecutar
// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome
```

---

## 6. Best Practices

✅ **DO's:**
- Diseñar responsive
- Testar en múltiples dispositivos
- Optimizar para web (performance)
- Usar adaptive widgets
- Configurar shortcuts
- Manejar window events

❌ **DON'Ts:**
- Hardcodear tamaños
- Ignorar responsive design
- Mezclar código específico de plataforma
- Olvidar testar en web/desktop
- No optimizar assets

---

## 7. Ejercicios

### Ejercicio 1: App Responsive
Crear app que funcione perfectamente en mobile, tablet y desktop

### Ejercicio 2: Desktop App
Crear aplicación nativa para Windows/macOS

### Ejercicio 3: PWA
Crear Progressive Web App instalable

---

Conceptos Relacionados:
- 08_TEMAS_THEMES
- 09_RESPONSIVE_DESIGN
- 19_PUBLICACION_STORES
- 21_INTERNACIONALIZACION
- EJERCICIOS_25_WEB_DESKTOP

## Resumen

Flutter multi-plataforma permite:
- ✅ Código compartido
- ✅ Desarrollo rápido
- ✅ Un producto, múltiples plataformas
- ✅ Misma calidad en todas partes
