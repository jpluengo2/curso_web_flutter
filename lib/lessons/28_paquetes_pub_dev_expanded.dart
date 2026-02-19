import 'package:flutter/material.dart';

class Lab28Paquetes extends StatelessWidget {
  const Lab28Paquetes({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 28: Catálogo pub.dev", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        const Text("Los paquetes más usados en el ecosistema Flutter. Toca 'Instalar' para ver el comando.", textAlign: TextAlign.center),
        const SizedBox(height: 20),

        _buildSectionHeader("1. UI & Diseño"),
        _buildExampleCard("Fuentes e Iconos", const PackageList(category: "ui")),
        
        const SizedBox(height: 30),
        _buildSectionHeader("2. Funcionalidad"),
        _buildExampleCard("Utilidades Esenciales", const PackageList(category: "utils")),

        const SizedBox(height: 30),
        _buildSectionHeader("3. Backend & Data"),
        _buildExampleCard("Datos y Redes", const PackageList(category: "data")),
        
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

class PackageList extends StatelessWidget {
  final String category;
  const PackageList({super.key, required this.category});

  List<Map<String, String>> get _packages {
    if (category == "ui") {
      return [
        {"name": "google_fonts", "desc": "1000+ fuentes gratuitas.", "ver": "^6.1.0"},
        {"name": "flutter_svg", "desc": "Renderizado de archivos SVG.", "ver": "^2.0.9"},
        {"name": "lottie", "desc": "Animaciones vectoriales AfterEffects.", "ver": "^3.0.0"},
        {"name": "shimmer", "desc": "Efectos de carga (esqueleto).", "ver": "^3.0.0"},
      ];
    } else if (category == "utils") {
      return [
        {"name": "url_launcher", "desc": "Abrir enlaces y correos.", "ver": "^6.2.0"},
        {"name": "share_plus", "desc": "Compartir contenido nativo.", "ver": "^7.2.0"},
        {"name": "permission_handler", "desc": "Gestión fácil de permisos.", "ver": "^11.0.0"},
        {"name": "device_info_plus", "desc": "Info del modelo y OS.", "ver": "^9.0.0"},
      ];
    } else {
      return [
        {"name": "http", "desc": "Peticiones web básicas.", "ver": "^1.1.0"},
        {"name": "dio", "desc": "Cliente HTTP potente.", "ver": "^5.3.0"},
        {"name": "sqflite", "desc": "Base de datos SQL local.", "ver": "^2.3.0"},
        {"name": "firebase_core", "desc": "Inicialización de Firebase.", "ver": "^2.20.0"},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _packages.map((pkg) => ListTile(
        title: Text(pkg['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        subtitle: Text(pkg['desc']!),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Terminal: flutter pub add ${pkg['name']}"),
              duration: const Duration(seconds: 2),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
          child: const Text("Instalar"),
        ),
      )).toList(),
    );
  }
}