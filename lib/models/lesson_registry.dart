import 'package:flutter/material.dart';

// Importamos el archivo del laboratorio real. 
// Asegúrate de que el archivo LAB_01... esté en la carpeta lib/lessons/
import '../lessons/01_FUNDAMENTOS_WIDGETS_BASICOS.dart';
import '../lessons/02_STATEFUL_STATELESS_LIFECYCLE.dart';
import '../lessons/03_ADVANCED_BUILDERS_STREAMS_FUTURE.dart';
import '../lessons/04_LISTVIEW_SCROLLVIEW.dart';
import '../lessons/05_RUTAS_ROUTING.dart';
import '../lessons/06_SCAFFOLD_NAVEGACION.dart';
import '../lessons/07_FORMULARIOS.dart';

final Map<String, Widget> lessonRegistry = {
  // Conectamos el ID "01" con la clase correcta que creamos antes
  "01": const Lab01FundamentosWidgets(), 
  "02": const Lab02StatefulStateless(),
  "03": const Lab03AdvancedBuilders(),
  "04": const Lab04ListViews(),
  "05": const Lab05Rutas(),
  "06": const Lab06Scaffold(),
  "07": const Lab07Formularios(),
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