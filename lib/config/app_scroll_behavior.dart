import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// CONFIGURACIÓN DEL COMPORTAMIENTO DE SCROLL
/// Esto es vital para que la app responda al arrastre del ratón en Web/Desktop,
/// no solo al táctil.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // Habilita arrastrar listas con el ratón
      };
}