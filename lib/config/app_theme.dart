import 'package:flutter/material.dart';

/// Centraliza la configuración de temas de la aplicación.
class AppTheme {
  // Color primario principal (Un azul vibrante y moderno)
  static const Color _seedColor = Color(0xFF2563EB);

  /// Define el tema claro para la aplicación.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      scrollbarTheme: _scrollbarTheme(colorScheme),
    );
  }

  /// Define el tema oscuro para la aplicación (Estándar suave y legible).
  static ThemeData get darkTheme {
    // Generamos el esquema de colores partiendo de nuestro azul, pero en versión oscura
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    // Partimos del tema oscuro BASE oficial de Flutter para asegurar 
    // que todos los textos por defecto sean blancos/claros y 100% legibles.
    final baseTheme = ThemeData.dark(useMaterial3: true);

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      
      // Colores de fondo estándar de Material Design (Gris oscuro suave, no negro puro ni azulado)
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      // Aplicamos nuestro scrollbar personalizado
      scrollbarTheme: _scrollbarTheme(colorScheme),
    );
  }

  /// Método auxiliar para unificar el estilo de las barras de scroll
  static ScrollbarThemeData _scrollbarTheme(ColorScheme scheme) {
    return ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      trackVisibility: WidgetStateProperty.all(true),
      thumbColor: WidgetStateProperty.all(scheme.onSurface.withOpacity(0.3)),
      trackColor: WidgetStateProperty.all(scheme.onSurface.withOpacity(0.05)),
      thickness: WidgetStateProperty.all(8),
      radius: const Radius.circular(8),
      interactive: true,
    );
  }
}