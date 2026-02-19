import 'package:flutter/material.dart';

// Importamos el archivo del laboratorio real. 
// Se actualizan todos los imports para usar el estilo lower_case_with_underscores.
import '../lessons/01_fundamentos_widgets_basicos.dart';
import '../lessons/02_stateful_stateless_lifecycle.dart';
import '../lessons/03_advanced_builders_streams_future.dart';
import '../lessons/04_listview_scrollview.dart';
import '../lessons/05_rutas_routing.dart';
import '../lessons/06_scaffold_navegacion.dart';
import '../lessons/07_formularios.dart';
import '../lessons/08_temas_themes.dart';
import '../lessons/09_responsive_design.dart';
import '../lessons/10_animaciones.dart';
import '../lessons/11_gestures_eventos.dart';
import '../lessons/12_gestion_estado.dart';
import '../lessons/13_persistencia_datos.dart';
import '../lessons/14_consumo_apis.dart';
import '../lessons/15_firebase.dart';
import '../lessons/16_testing.dart';
import '../lessons/17_manejo_errores.dart';
import '../lessons/18_widgets_avanzados.dart';
import '../lessons/19_performance_optimization.dart';
import '../lessons/20_riverpod_state_management.dart';
import '../lessons/21_internacionalizacion.dart';
import '../lessons/22_clean_architecture.dart';
import '../lessons/23_device_access.dart';
import '../lessons/24_monetizacion_appstore.dart';
import '../lessons/25_web_desktop.dart';
import '../lessons/26_cambiar_icono_branding.dart';
import '../lessons/27_organizacion_carpetas.dart';
import '../lessons/28_paquetes_pub_dev_expanded.dart';
import '../lessons/29_paquetes_pub_dev.dart';

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
  "19": const Lab19PerformanceOptimization(),
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