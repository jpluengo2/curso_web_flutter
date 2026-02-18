# Temas (Themes) en Flutter - Guía completa

## 📚 Tabla de contenidos
1. [Introducción](#introducción)
2. [¿Qué es un Theme?](#qué-es-un-theme)
3. [ThemeData: La base de los temas](#themedata-la-base-de-los-temas)
4. [ColorScheme](#colorscheme)
5. [Propiedades principales de ThemeData](#propiedades-principales-de-themedata)
6. [Cómo crear y aplicar temas](#cómo-crear-y-aplicar-temas)
7. [Temas claros y oscuros](#temas-claros-y-oscuros)
8. [Extensión de temas](#extensión-de-temas)
9. [Casos de uso prácticos](#casos-de-uso-prácticos)
10. [Buenas prácticas](#buenas-prácticas)

---

## Introducción

Los **temas (themes)** en Flutter son un mecanismo fundamental para crear aplicaciones consistentes y profesionales. Permiten definir una paleta de colores, tipografía, espaciado y estilos visuales que se aplican en toda la aplicación.

Imagina que trabajas en una empresa importante y la marca requiere que toda la aplicación tenga colores específicos, fuentes particulares y un estilo consistente. En lugar de configurar cada elemento individualmente, los temas permiten hacer esto de forma centralizada y reutilizable.

### ¿Por qué son importantes los temas?

- **Consistencia visual**: Toda la aplicación tiene el mismo aspecto y sensación
- **Mantenibilidad**: Cambiar la paleta de colores es cuestión de segundos
- **Accesibilidad**: Facilita implementar temas claros y oscuros
- **Marca corporativa**: Asegura que la aplicación siga los estándares de diseño de la empresa
- **Experiencia del usuario**: Los usuarios obtienen una experiencia coherente y profesional

---

## ¿Qué es un Theme?

Un **theme** es un conjunto de propiedades visuales que define cómo se vería la interfaz de usuario. Incluye:

- **Paleta de colores**: Colores primarios, secundarios, de fondo, etc.
- **Tipografía**: Fuentes, tamaños y estilos de texto
- **Formas**: Bordes redondeados, sombras, etc.
- **Comportamiento visual**: Opacidades, animaciones, etc.

### Analogía del mundo real

Si piensas en una aplicación móvil como un restaurante:

- El **ColorScheme** sería la paleta de colores del interior (paredes, mesas, decoración)
- La **tipografía** sería el estilo de las letras en los menús y señales
- La **AppBarTheme** sería el diseño de la recepción
- Los **ButtonStyles** serían el diseño de los botones de las mesas

---

## ThemeData: La base de los temas

`ThemeData` es la clase central que define un tema completo en Flutter. Contiene todas las configuraciones visuales que se aplicarán a los widgets.

### Ejemplo básico

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Mi Aplicación',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hola Tema')),
      body: Center(child: Text('Este es mi primer tema')),
    );
  }
}
```

---

## ColorScheme

El `ColorScheme` es una estructura organizada que define los colores principales de tu aplicación siguiendo las directrices de Material Design 3.

### Colores principales en ColorScheme

```dart
ColorScheme(
  brightness: Brightness.light,        // Claro u oscuro
  primary: Colors.blue,                // Color primario
  onPrimary: Colors.white,             // Color sobre el primario (texto, iconos)
  primaryContainer: Colors.lightBlue,  // Contenedor del primario
  onPrimaryContainer: Colors.black,    // Texto sobre el contenedor primario
  
  secondary: Colors.orange,            // Color secundario
  onSecondary: Colors.white,           // Texto sobre secundario
  
  tertiary: Colors.green,              // Color terciario (nuevo en MD3)
  onTertiary: Colors.white,            // Texto sobre terciario
  
  error: Colors.red,                   // Color de error
  onError: Colors.white,               // Texto en error
  
  surface: Colors.white,               // Superficie (fondo)
  onSurface: Colors.black,             // Texto sobre superficie
  
  outline: Colors.grey,                // Bordes
)
```

### Crear ColorScheme automáticamente desde un color

```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,              // Color base
  brightness: Brightness.light,        // Generar colores claros
);
```

### Ejemplo completo con ColorScheme

import 'package:flutter/material.dart';
class HomePage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(); }
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    );

    return MaterialApp(
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ColorScheme Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.all(16),
              child: Text(
                'Color Primario',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.all(16),
              child: Text(
                'Color Secundario',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Propiedades principales de ThemeData

### 1. Tipografía (TextTheme)

Define los estilos de texto predefinidos:

```dart
ThemeData(
  textTheme: TextTheme(
    displayLarge: TextStyle(      // Títulos muy grandes
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(     // Títulos grandes
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(      // Títulos medianos
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(    // Encabezados
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(         // Cuerpo de texto grande
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(        // Cuerpo de texto normal
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(         // Cuerpo de texto pequeño
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
  ),
)
```

### 2. AppBar Theme

Personaliza la barra superior:

```dart
ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,  // Color del texto e iconos
    elevation: 4,                   // Sombra
    centerTitle: true,              // Centra el título
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### 3. Button Themes

Personaliza botones:

```dart
ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.blue,
      side: BorderSide(color: Colors.blue),
    ),
  ),
)
```

### 4. Input Decorations

Personaliza campos de texto:

```dart
ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: EdgeInsets.all(16),
  ),
)
```

### 5. Floating Action Button Theme

```dart
ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 8,
    shape: CircleBorder(),
  ),
)
```

---

## Cómo crear y aplicar temas

### Opción 1: Tema simple y directo

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
```

### Opción 2: Tema personalizado completo

import 'package:flutter/material.dart';
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildCustomTheme(),
      home: HomePage(),
    );
  }
}

ThemeData buildCustomTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 2,
    ),
  );
}
```

### Opción 3: Acceder a los colores del tema en tu código

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener el tema actual
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Página'),
      ),
      body: Center(
        child: Container(
          color: colorScheme.primary,
          padding: EdgeInsets.all(16),
          child: Text(
            'Este texto usa el color del tema',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Temas claros y oscuros

Una de las características más poderosas de los temas es la capacidad de crear versiones claras y oscuras.

### Implementar tema claro y oscuro

import 'package:flutter/material.dart';
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        isDarkMode: isDarkMode,
        onThemeToggle: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}

class HomePage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomePage({
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tema Claro/Oscuro'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Modo ${isDarkMode ? 'Oscuro' : 'Claro'}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
```

### Usar el tema del sistema automáticamente

```dart
MaterialApp(
  theme: _buildLightTheme(),
  darkTheme: _buildDarkTheme(),
  themeMode: ThemeMode.system,  // Sigue la preferencia del sistema
  home: HomePage(),
)
```

---

## Extensión de temas

En proyectos grandes, es común querer compartir temas entre múltiples archivos. Aquí hay algunas estrategias:

### Crear un archivo de constantes de temas

**lib/theme/app_theme.dart**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colores personalizados
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textDarkColor = Color(0xFF212121);
  static const Color textLightColor = Color(0xFF757575);

  // Espaciado
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Radio de bordes
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  // Temas
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      scaffoldBackgroundColor: backgroundColor,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: _buildDarkTextTheme(),
      appBarTheme: _buildDarkAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      scaffoldBackgroundColor: Color(0xFF121212),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDarkColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDarkColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textDarkColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textLightColor,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white54,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    );
  }

  static AppBarTheme _buildDarkAppBarTheme() {
    return AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
    );
  }
}
```

### Usar el archivo de temas en main.dart

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
```

---

## Casos de uso prácticos

### Caso 1: Aplicación con múltiples marcas

```dart
enum BrandTheme {
  blue,
  red,
  green,
}

class BrandedApp extends StatefulWidget {
  @override
  State<BrandedApp> createState() => _BrandedAppState();
}

class _BrandedAppState extends State<BrandedApp> {
  BrandTheme currentBrand = BrandTheme.blue;

  ThemeData _getBrandTheme(BrandTheme brand) {
    final Color seedColor = {
      BrandTheme.blue: Colors.blue,
      BrandTheme.red: Colors.red,
      BrandTheme.green: Colors.green,
    }[brand]!;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _getBrandTheme(currentBrand),
      home: Scaffold(
        appBar: AppBar(title: Text('Cambiar Marca')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: BrandTheme.values.map((brand) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentBrand = brand;
                    });
                  },
                  child: Text('Tema ${brand.name}'),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
```

### Caso 2: Aplicación de comercio electrónico

```dart
class EcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.amber,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        displayMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
    );

    return MaterialApp(
      theme: theme,
      home: ProductListPage(),
    );
  }
}

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Producto ${index + 1}',
                  style: Theme.of(context).textTheme.displayMedium),
              subtitle: Text('\$99.99'),
              trailing: Icon(Icons.arrow_forward),
            ),
          );
        },
      ),
    );
  }
}
```

### Caso 3: Aplicación educativa con temas especializados

```dart
class EducationalApp extends StatefulWidget {
  @override
  State<EducationalApp> createState() => _EducationalAppState();
}

class _EducationalAppState extends State<EducationalApp> {
  bool isAccessibilityMode = false;

  ThemeData _buildEducationalTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: isAccessibilityMode ? 28 : 24,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          fontSize: isAccessibilityMode ? 18 : 14,
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildEducationalTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Educación'),
          actions: [
            IconButton(
              icon: Icon(isAccessibilityMode
                  ? Icons.accessibility_new
                  : Icons.accessibility),
              onPressed: () {
                setState(() {
                  isAccessibilityMode = !isAccessibilityMode;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Text(
            'Modo Accesibilidad: ${isAccessibilityMode ? 'Activado' : 'Desactivado'}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
      ),
    );
  }
}
```

---

## Buenas prácticas

### ✅ DO: Hacer esto

```dart
// Usar Theme.of(context) para acceder a estilos
Text(
  'Título',
  style: Theme.of(context).textTheme.headlineMedium,
)

// Centralizar los temas en un archivo
// Usar constantes para valores repetidos
static const double paddingDefault = 16.0;

// Mantener consistencia en nombres
// Usar Material Design 3 (useMaterial3: true)
ThemeData(
  useMaterial3: true,
  // ...
)

// Probar temas en diferentes tamaños de pantalla
// Implementar tema oscuro y claro
// Documentar la intención de cada color
```

### ❌ DON'T: No hacer esto

```dart
// No hardcodear colores en cada widget
Text(
  'Título',
  style: TextStyle(color: Color(0xFF2196F3)),
)

// No duplicar estilos
// No ignorar ColorScheme
// No crear temas inconsistentes entre luz y oscuridad
// No usar colores sin contraste adecuado (accesibilidad)
```

### Checklist de implementación

- [ ] Crear un archivo centralizado para temas (ej: `lib/theme/app_theme.dart`)
- [ ] Definir una paleta de colores consistente
- [ ] Implementar tanto tema claro como oscuro
- [ ] Usar `Theme.of(context)` en lugar de hardcodear valores
- [ ] Probar los temas en luz y oscuridad
- [ ] Asegurar contraste adecuado para accesibilidad
- [ ] Documentar la intención de cada color
- [ ] Usar Material Design 3 (`useMaterial3: true`)
- [ ] Probar en diferentes tamaños de pantalla
- [ ] Validar que la marca se refleje en todo el tema

---

## Resumen

Los **temas en Flutter** son fundamentales para crear aplicaciones profesionales y consistentes. Mediante `ThemeData` y `ColorScheme`, puedes:

1. **Definir una identidad visual centralizada**
2. **Facilitar cambios globales de estilo**
3. **Implementar temas claros y oscuros**
4. **Mejorar la accesibilidad**
5. **Mantener código limpio y reutilizable**

Recuerda: un buen tema es invisible para el usuario, pero la falta de uno es evidente. ¡Invierte tiempo en crear temas bien diseñados y tu aplicación lucirá profesional! 🎨

---

## Enlaces útiles

- [Documentación oficial de ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [ColorScheme en Flutter](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [Material Design 3](https://m3.material.io/)
- [Guía de accesibilidad en Flutter](https://flutter.dev/accessibility)

---

## Preguntas frecuentes

**P: ¿Puedo cambiar el tema dinámicamente sin reiniciar la aplicación?**
R: Sí, usando `StatefulWidget` y `setState()` para actualizar el `themeMode` o creando un `ChangeNotifier` con Provider.

**P: ¿Cuál es la diferencia entre `primaryColor` y `primary` en `ColorScheme`?**
R: `primaryColor` es antiguo (deprecated), mientras que `primary` en `ColorScheme` es la forma moderna de Material Design 3.

**P: ¿Cómo aseguro que mi tema sea accesible?**
R: Verifica el contraste de colores (mínimo 4.5:1 para texto). Usa herramientas como WebAIM Contrast Checker.

**P: ¿Puedo usar fuentes personalizadas en el tema?**
R: Sí, agregándolas a `pubspec.yaml` y definiéndolas en `TextTheme`.

---

Conceptos Relacionados:
- 01_FUNDAMENTOS_WIDGETS_BASICOS
- 06_SCAFFOLD_NAVEGACION
- 09_RESPONSIVE_DESIGN
- 18_WIDGETS_AVANZADOS
- EJERCICIOS_08_TEMAS_THEMES

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio**
