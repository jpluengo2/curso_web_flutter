import 'package:flutter/material.dart';
import 'package:curso_web_flutter/config/app_scroll_behavior.dart';
import 'package:curso_web_flutter/config/app_theme.dart';
import 'package:curso_web_flutter/providers/notebook_provider.dart';
import 'package:provider/provider.dart';
import 'ui/pages/home_page.dart';

void main() {
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
      
      theme: AppTheme.lightTheme,
      
      // PANTALLA PRINCIPAL
      home: const NotebookHomePage(),
    );
  }
}