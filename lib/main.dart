import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:curso_web_flutter/config/app_scroll_behavior.dart';
import 'package:curso_web_flutter/config/app_theme.dart';
import 'package:curso_web_flutter/providers/notebook_provider.dart';
import 'package:provider/provider.dart';
import 'ui/pages/home_page.dart';

void main() {
  // Asegura que los bindings de Flutter estén inicializados.
  // Es necesario si se realizan operaciones asíncronas antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // --- MEJORA: MANEJO DE ERRORES GLOBAL ---
  // Captura errores del framework Flutter (ej. errores de layout durante build).
  FlutterError.onError = (details) {
    // En un proyecto real, aquí se enviarían los errores a un servicio
    // de monitoreo como Sentry, Firebase Crashlytics, etc.
    // Por ahora, los mostraremos en la consola para depuración.
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError.onError: ${details.exception}');
    }
  };

  // Captura errores de Dart que no fueron atrapados por el framework Flutter
  // (ej. excepciones en código asíncrono como Futures o Streams).
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('PlatformDispatcher.onError: $error');
    }
    // Devuelve `true` para indicar que el error ha sido manejado.
    return true;
  };

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotebookProvider(),
      child: const FlutterNotebookApp(),
    ),
  );
}

class FlutterNotebookApp extends StatelessWidget {
  const FlutterNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curso Flutter Web',
      debugShowCheckedModeBanner: false,
      
      // Aplicamos el comportamiento de scroll personalizado
      scrollBehavior: MyCustomScrollBehavior(),

      // --- MEJORA: SOPORTE PARA TEMA CLARO Y OSCURO ---
      // Se definen ambos temas y se usa `themeMode` para que la app
      // responda a la configuración del sistema operativo.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // PANTALLA PRINCIPAL
      home: const NotebookHomePage(),
    );
  }
}