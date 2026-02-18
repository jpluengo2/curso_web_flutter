import 'package:flutter/material.dart';

// Importamos el archivo del laboratorio real. 
// Asegúrate de que el archivo LAB_01... esté en la carpeta lib/lessons/
import '../lessons/01_FUNDAMENTOS_WIDGETS_BASICOS.dart';

final Map<String, Widget> lessonRegistry = {
  // Conectamos el ID "01" con la clase correcta que creamos antes
  "01": const Lab01FundamentosWidgets(), 
};

const Widget defaultPlaceholder = Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.construction, size: 40, color: Colors.grey),
      SizedBox(height: 10),
      Text("Laboratorio no disponible", style: TextStyle(color: Colors.grey)),
    ],
  ),
);