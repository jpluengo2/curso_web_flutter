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
import '../lessons/08_TEMAS_THEMES.dart';
import '../lessons/09_RESPONSIVE_DESIGN.dart';
import '../lessons/10_ANIMACIONES.dart';
import '../lessons/11_GESTURES_EVENTOS.dart';
import '../lessons/12_GESTION_ESTADO.dart';
import '../lessons/13_PERSISTENCIA_DATOS.dart';
import '../lessons/14_CONSUMO_APIS.dart';
import '../lessons/15_FIREBASE.dart';
import '../lessons/16_TESTING.dart';
import '../lessons/17_MANEJO_ERRORES.dart';
import '../lessons/18_WIDGETS_AVANZADOS.dart';
import '../lessons/19_PERFORMANCE_OPTIMIZATION.dart';
import '../lessons/20_RIVERPOD_STATE_MANAGEMENT.dart';
import '../lessons/21_INTERNACIONALIZACION.dart';
import '../lessons/22_CLEAN_ARCHITECTURE.dart';
import '../lessons/23_DEVICE_ACCESS.dart';
import '../lessons/24_MONETIZACION_APPSTORE.dart';
import '../lessons/25_WEB_DESKTOP.dart';
import '../lessons/26_CAMBIAR_ICONO_BRANDING.dart';
import '../lessons/27_ORGANIZACION_CARPETAS.dart';
import '../lessons/28_PAQUETES_PUB_DEV_EXPANDED.dart';
import '../lessons/29_PAQUETES_PUB_DEV.dart';

final Map<String, Widget> lessonRegistry = {
  // Conectamos el ID "01" con la clase correcta que creamos antes
  "01": const Lab01FundamentosWidgets(), 
  "02": const Lab02StatefulStateless(),
  "03": const Lab03AdvancedBuilders(),
  "04": const Lab04ListViews(),
  "05": const Lab05Rutas(),
  "06": const Lab06Scaffold(),
  "07": const Lab07Formularios(),
  "08": const Lab08Themes(),
  "09": const Lab09Responsive(),
  "10": const Lab10Animaciones(),
  "11": const Lab11Gestures(),
  "12": const Lab12GestionEstado(),
  "13": const Lab13Persistencia(),
  "14": const Lab14ConsumoApis(),
  "15": const Lab15Firebase(),
  "16": const Lab16Testing(),
  "17": const Lab17ManejoErrores(),
  "18": const Lab18WidgetsAvanzados(),
  "19": const Lab19Performance(),
  "20": const Lab20Riverpod(),
  "21": const Lab21Internacionalizacion(),
  "22": const Lab22CleanArch(),
  "23": const Lab23DeviceAccess(),
  "24": const Lab24Monetizacion(),
  "25": const Lab25WebDesktop(),
  "26": const Lab26Branding(),
  "27": const Lab27Estructura(),
  "28": const Lab28Paquetes(),
  "29": const Lab29GestionDependencias(),
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