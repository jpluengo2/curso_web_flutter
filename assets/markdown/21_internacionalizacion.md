# Internacionalización (i18n) en Flutter: Guía Completa

## Introducción a i18n

La internacionalización permite que tu app soporte múltiples idiomas y localizaciones (fechas, moneda, etc.). Es fundamental para apps que se distribuyen globalmente.

### Beneficios

- ✅ Alcance global
- ✅ Múltiples idiomas
- ✅ Formatos locales (fechas, moneda)
- ✅ RTL (idiomas de derecha a izquierda)
- ✅ Mejor experiencia de usuario

---

## 1. Setup Inicial

### 1.1 Agregar Dependencias

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  # Opcional pero recomendado
  get_it: ^7.6.0
  provider: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 1.2 Estructura de Carpetas

```
lib/
├── l10n/
│   ├── app_en.arb
│   ├── app_es.arb
│   ├── app_fr.arb
│   └── app_de.arb
├── main.dart
└── ...

# .arb = Application Resource Bundle (formato JSON)
```

### 1.3 Crear Archivos .arb

```json
// lib/l10n/app_en.arb
{
  "hello": "Hello",
  "welcome": "Welcome {name}",
  "itemCount": "{count, plural, =0{No items} one{1 item} other{{count} items}}",
  "appTitle": "My App",
  "settings": "Settings",
  "language": "Language",
  "theme": "Theme",
  "logout": "Logout",
  "loading": "Loading...",
  "error": "An error occurred",
  "retry": "Retry",
  "noData": "No data available"
}

// lib/l10n/app_es.arb
{
  "hello": "Hola",
  "welcome": "Bienvenido {name}",
  "itemCount": "{count, plural, =0{Sin elementos} one{1 elemento} other{{count} elementos}}",
  "appTitle": "Mi Aplicación",
  "settings": "Configuración",
  "language": "Idioma",
  "theme": "Tema",
  "logout": "Cerrar sesión",
  "loading": "Cargando...",
  "error": "Ocurrió un error",
  "retry": "Reintentar",
  "noData": "No hay datos disponibles"
}

// lib/l10n/app_fr.arb
{
  "hello": "Bonjour",
  "welcome": "Bienvenue {name}",
  "itemCount": "{count, plural, =0{Pas d'éléments} one{1 élément} other{{count} éléments}}",
  "appTitle": "Mon Application",
  "settings": "Paramètres",
  "language": "Langue",
  "theme": "Thème",
  "logout": "Déconnexion",
  "loading": "Chargement...",
  "error": "Une erreur s'est produite",
  "retry": "Réessayer",
  "noData": "Aucune donnée disponible"
}

// lib/l10n/app_de.arb
{
  "hello": "Hallo",
  "welcome": "Willkommen {name}",
  "itemCount": "{count, plural, =0{Keine Elemente} one{1 Element} other{{count} Elemente}}",
  "appTitle": "Meine Anwendung",
  "settings": "Einstellungen",
  "language": "Sprache",
  "theme": "Design",
  "logout": "Abmelden",
  "loading": "Wird geladen...",
  "error": "Ein Fehler ist aufgetreten",
  "retry": "Erneut versuchen",
  "noData": "Keine Daten verfügbar"
}
```

### 1.4 Configurar pubspec.yaml

```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  generate: true  # ← Habilitar generación de código i18n

flutter_gen:
  output: lib/gen_l10n  # Carpeta donde se generan los archivos
  line_length: 80

# O especificar la configuración de i18n
flutter_intl:
  enabled: true
```

### 1.5 Generar Código

```bash
# Generar archivos de localización
flutter gen-l10n

# O ejecutar pub get
flutter pub get
```

---

## 2. Setup en main.dart

### 2.1 Configurar App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  // Acceso global
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  // Cambiar idioma
  void setLocale(Locale locale) {
    setState(() => _locale = locale);
    
    // Guardar preferencia
    _saveLocale(locale);
  }

  Future<void> _saveLocale(Locale locale) async {
    // Guardar en SharedPreferences o similar
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      
      // ← Configuración i18n
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Idiomas soportados
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
      ],
      
      // Idioma actual
      locale: _locale,
      
      // Callback para cuando el idioma del sistema no es soportado
      localeResolutionCallback: (locale, supportedLocales) {
        // Intentar encontir idioma exacto
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Por defecto
        return supportedLocales.first;
      },
      
      home: const HomeScreen(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
```

---

## 3. Usar Localizaciones

### 3.1 Acceder a Strings

```dart
import 'gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener AppLocalizations
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle), // ← Traducido automáticamente
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.hello),
            Text(l10n.welcome(name: 'Juan')), // ← Con parámetro
            Text(l10n.itemCount(count: 5)), // ← Pluralización
          ],
        ),
      ),
    );
  }
}
```

### 3.2 Usar en Widgets

```dart
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final myApp = MyApp.of(context);

    return Column(
      children: [
        ListTile(
          title: Text('English'),
          onTap: () => myApp?.setLocale(const Locale('en')),
        ),
        ListTile(
          title: Text('Español'),
          onTap: () => myApp?.setLocale(const Locale('es')),
        ),
        ListTile(
          title: Text('Français'),
          onTap: () => myApp?.setLocale(const Locale('fr')),
        ),
        ListTile(
          title: Text('Deutsch'),
          onTap: () => myApp?.setLocale(const Locale('de')),
        ),
      ],
    );
  }
}
```

---

## 4. Formateo de Fechas y Números

### 4.1 Fechas Localizadas

```dart
import 'package:intl/intl.dart';

class DateFormatting {
  // Formatear fecha según idioma
  static String formatDate(DateTime date, Locale locale) {
    final formatter = DateFormat('dd/MM/yyyy', locale.toString());
    return formatter.format(date);
  }

  // Fecha completa
  static String formatFullDate(DateTime date, Locale locale) {
    final formatter = DateFormat('EEEE, d MMMM y', locale.toString());
    return formatter.format(date);
  }

  // Hora
  static String formatTime(DateTime date, Locale locale) {
    final formatter = DateFormat('HH:mm:ss', locale.toString());
    return formatter.format(date);
  }

  // Fecha y hora
  static String formatDateTime(DateTime date, Locale locale) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', locale.toString());
    return formatter.format(date);
  }
}
```

// Uso
class DateFormatExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);

    return Column(
      children: [
        Text(DateFormatting.formatDate(now, locale)),
        Text(DateFormatting.formatFullDate(now, locale)),
        Text(DateFormatting.formatTime(now, locale)),
      ],
    );
  }
}
```

### 4.2 Números y Moneda

```dart
class NumberFormatting {
  // Número con decimales
  static String formatNumber(double number, Locale locale) {
    final formatter = NumberFormat('0.00', locale.toString());
    return formatter.format(number);
  }

  // Moneda
  static String formatCurrency(double amount, Locale locale, String symbol) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale.toString(),
      name: symbol,
    );
    return formatter.format(amount);
  }

  // Porcentaje
  static String formatPercent(double value, Locale locale) {
    final formatter = NumberFormat.percentPattern(locale.toString());
    return formatter.format(value);
  }

  // Número compacto (1.2M, 3.5K)
  static String formatCompact(double value, Locale locale) {
    final formatter = NumberFormat.compact(locale: locale.toString());
    return formatter.format(value);
  }
}
```

// Uso
class PriceDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Column(
      children: [
        // USD
        Text(NumberFormatting.formatCurrency(99.99, locale, 'USD')),
        // EUR
        Text(NumberFormatting.formatCurrency(89.99, locale, 'EUR')),
        // Porcentaje
        Text(NumberFormatting.formatPercent(0.15, locale)),
      ],
    );
  }
}
```

---

## 5. RTL (Derecha a Izquierda)

### 5.1 Soporte RTL

```dart
// Los idiomas RTL (Árabe, Hebreo) se detectan automáticamente
// Pero puedes forzar

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return MaterialApp(
      title: 'Mi Aplicación',
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ar'), // Árabe (RTL)
        Locale('he'), // Hebreo (RTL)
      ],
      localizationsDelegates: const [
        // ...
      ],
    );
  }
}

// Widgets que responden a RTL
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        if (!isRTL)
          const Icon(Icons.arrow_forward)
        else
          const Icon(Icons.arrow_back),
        const SizedBox(width: 16),
        const Text('Contenido'),
      ],
    );
  }
}
```

---

## 6. Pluralización

### 6.1 Plurales en .arb

```json
{
  "items": "{count, plural, =0{No hay items} one{Un item} other{{count} items}}"
}

// En español
{
  "items": "{count, plural, =0{No hay elementos} one{Un elemento} other{{count} elementos}}"
}
```

### 6.2 Usar Plurales

```dart
class ItemCounter extends StatelessWidget {
  final int count;

  const ItemCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text(l10n.items(count: count));
    
    // Output:
    // count=0: "No hay elementos"
    // count=1: "Un elemento"
    // count=5: "5 elementos"
  }
}
```

---

## 7. Contexto con Provider

### 7.1 LocaleProvider

```dart
import 'package:provider/provider.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
    
    // Guardar preferencia
    _saveLocale(locale);
  }

  Future<void> _saveLocale(Locale locale) async {
    // Implementar guardado en SharedPreferences
  }
}

// En main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp(
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
          ],
          home: const HomeScreen(),
        );
      },
    );
  }
}
```

### 7.2 Cambiar Idioma con Provider

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Column(
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () => localeProvider.setLocale(const Locale('en')),
          ),
          ListTile(
            title: const Text('Español'),
            onTap: () => localeProvider.setLocale(const Locale('es')),
          ),
          ListTile(
            title: const Text('Français'),
            onTap: () => localeProvider.setLocale(const Locale('fr')),
          ),
          ListTile(
            title: const Text('Deutsch'),
            onTap: () => localeProvider.setLocale(const Locale('de')),
          ),
        ],
      ),
    );
  }
}
```

---

## 8. Testing i18n

### 8.1 Test de Localizaciones

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gen_l10n/app_localizations.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('Verify English strings', (WidgetTester tester) async {
      const locale = Locale('en');
      
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.hello);
              },
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Verify Spanish strings', (WidgetTester tester) async {
      const locale = Locale('es');
      
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.hello);
              },
            ),
          ),
        ),
      );

      expect(find.text('Hola'), findsOneWidget);
    });
  });
}
```

---

## 9. Agregar Nuevos Idiomas

### 9.1 Nuevo Idioma

1. Crear `lib/l10n/app_pt.arb` para portugués
2. Ejecutar `flutter gen-l10n`
3. Agregar `const Locale('pt')` a `supportedLocales`

### 9.2 Traducción Parcial

```json
// lib/l10n/app_pt.arb
{
  "hello": "Olá",
  "welcome": "Bem-vindo {name}",
  "itemCount": "{count, plural, =0{Sem itens} one{1 item} other{{count} itens}}"
  // Si falta una clave, se usa la del idioma por defecto
}
```

---

## 10. Best Practices

✅ **DO's:**
- Mantener consistencia en traducciones
- Usar contexto claro
- Traducir literales de strings
- Soportar RTL
- Testar cada idioma
- Usar plural forms
- Guardar preferencia del usuario

❌ **DON'Ts:**
- Hardcodear strings
- Olvidar traducir algo
- Hacer strings demasiado largos
- Usar máquina traductora sin revisión
- No soportar idioma del sistema
- Mezclar idiomas en un mismo archivo

---

## 11. Ejercicios

### Ejercicio 1: App Multiidioma Básica
Crear app con 3 idiomas (EN, ES, FR)

### Ejercicio 2: Tienda Online
Crear app con precios, fechas y moneda localizados

### Ejercicio 3: RTL Support
Crear app que soporte árabe y hebreo

---

Conceptos Relacionados:
- 08_TEMAS_THEMES
- 09_RESPONSIVE_DESIGN
- 19_PUBLICACION_STORES
- 25_WEB_DESKTOP
- EJERCICIOS_21_INTERNACIONALIZACION

## Resumen

i18n es esencial para:
- ✅ Alcance global
- ✅ Múltiples idiomas
- ✅ Formatos locales
- ✅ Mejor UX
- ✅ Cumplir expectativas de usuarios

Flutter lo hace simple con AppLocalizations.
