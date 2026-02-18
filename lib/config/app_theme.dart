import 'package:flutter/material.dart';

/// Centraliza la configuración de temas de la aplicación.
class AppTheme {
  /// Define el tema claro para la aplicación.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),

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

  /// Define el tema oscuro para la aplicación.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),

      // DISEÑO DE LAS BARRAS DE SCROLL (Scrollbars) PARA TEMA OSCURO
      // Ajustamos los colores para que tengan buen contraste sobre fondos oscuros.
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thumbColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.5)),
        trackColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(8),
        interactive: true,
      ),
    );
  }
}