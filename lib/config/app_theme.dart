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
      
      // Fondo general de la app (Un gris muy claro para que los paneles destaquen)
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      
      // DISEÑO DE LAS BARRAS DE SCROLL
      scrollbarTheme: _scrollbarTheme(colorScheme),
    );
  }

  /// Define el tema oscuro para la aplicación.
  static ThemeData get darkTheme {
    // En modo oscuro, usamos una paleta "Slate" (Pizarra/Medianoche).
    // Es mucho más elegante, moderna y legible que el negro puro o el gris por defecto.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      // Color de las superficies (paneles y tarjetas -> Azul medianoche medio)
      surface: const Color(0xFF1E293B),
      // Ajustamos el primario para que brille bien sobre fondo oscuro
      primary: const Color(0xFF3B82F6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      
      // Fondo general de la app (Azul medianoche muy profundo para crear profundidad)
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      
      // Suavizamos los textos para que el blanco puro no canse la vista (Accesibilidad)
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: const Color(0xFFE2E8F0), // Blanco roto/grisáceo
        displayColor: Colors.white,
      ),
      
      // Suavizamos los divisores y líneas
      dividerTheme: DividerThemeData(
        color: colorScheme.onSurface.withOpacity(0.15),
        thickness: 1,
      ),

      // DISEÑO DE LAS BARRAS DE SCROLL
      scrollbarTheme: _scrollbarTheme(colorScheme),
    );
  }

  /// Método auxiliar para unificar el estilo de las barras de scroll y 
  /// hacerlas adaptativas (se pintan solas en claro/oscuro)
  static ScrollbarThemeData _scrollbarTheme(ColorScheme scheme) {
    return ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      trackVisibility: WidgetStateProperty.all(true),
      // Usamos scheme.onSurface (el color principal del texto) con opacidad.
      // Así será gris oscuro en modo claro, y gris clarito en modo oscuro de forma automática.
      thumbColor: WidgetStateProperty.all(scheme.onSurface.withOpacity(0.3)),
      trackColor: WidgetStateProperty.all(scheme.onSurface.withOpacity(0.05)),
      thickness: WidgetStateProperty.all(8),
      radius: const Radius.circular(8),
      interactive: true,
    );
  }
}