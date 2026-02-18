import 'package:flutter/material.dart';

/// Centraliza la configuración de temas de la aplicación.
class AppTheme {
  /// Define el tema claro para la aplicación.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

      // DISEÑO DE LAS BARRAS DE SCROLL (Scrollbars)
      // Las hacemos siempre visibles y un poco más gruesas para uso en escritorio.
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true), // Siempre visible la "pastilla"
        trackVisibility: WidgetStateProperty.all(true), // Siempre visible el "carril"
        thumbColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.4)),
        trackColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.1)),
        thickness: WidgetStateProperty.all(8), // Grosor cómodo para el ratón
        radius: const Radius.circular(8),
        interactive: true,
      ),
    );
  }
}