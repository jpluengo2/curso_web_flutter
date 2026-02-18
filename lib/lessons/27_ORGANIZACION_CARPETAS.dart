import 'package:flutter/material.dart';

class Lab27Estructura extends StatelessWidget {
  const Lab27Estructura({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 27: Arquitectura de Carpetas", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        const Text("Explora la estructura recomendada para un proyecto escalable. Toca las carpetas para ver qué contienen.", textAlign: TextAlign.center),
        const SizedBox(height: 20),

        // --- PROJECT EXPLORER ---
        _buildExampleCard("Estructura Recomendada (Feature-First)", const ProjectStructureExplorer()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}



// 1. STRUCTURE EXPLORER
class ProjectStructureExplorer extends StatelessWidget {
  const ProjectStructureExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView(
        children: const [
          _FolderNode(name: "lib", children: [
            _FileNode(name: "main.dart", desc: "Punto de entrada. Configuración global."),
            _FolderNode(name: "config", children: [
              _FileNode(name: "theme.dart", desc: "Colores, fuentes y estilos."),
              _FileNode(name: "routes.dart", desc: "Mapa de navegación."),
            ]),
            _FolderNode(name: "core", children: [
              _FileNode(name: "constants.dart", desc: "Strings, URLs, Keys."),
              _FileNode(name: "utils.dart", desc: "Funciones de ayuda (fechas, format)."),
            ]),
            _FolderNode(name: "features (Módulos)", children: [
              _FolderNode(name: "auth", children: [
                _FileNode(name: "login_screen.dart", desc: "UI de inicio de sesión."),
                _FileNode(name: "auth_provider.dart", desc: "Lógica de estado."),
                _FileNode(name: "auth_service.dart", desc: "Conexión con API."),
              ]),
              _FolderNode(name: "products", children: [
                _FileNode(name: "product_list.dart", desc: "Pantalla de catálogo."),
                _FileNode(name: "product_model.dart", desc: "Clase de datos."),
              ]),
            ]),
            _FolderNode(name: "widgets (Globales)", children: [
              _FileNode(name: "custom_button.dart", desc: "Botón reutilizable en toda la app."),
            ]),
          ]),
          _FolderNode(name: "assets", children: [
            _FileNode(name: "images/", desc: "Logos, fondos."),
            _FileNode(name: "fonts/", desc: "Archivos .ttf o .otf"),
          ]),
          _FileNode(name: "pubspec.yaml", desc: "Dependencias y configuración."),
        ],
      ),
    );
  }
}

class _FolderNode extends StatelessWidget {
  final String name;
  final List<Widget> children;
  const _FolderNode({required this.name, required this.children});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.folder, color: Colors.amber),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 20),
      children: children,
    );
  }
}

class _FileNode extends StatelessWidget {
  final String name;
  final String desc;
  const _FileNode({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description, color: Colors.blueGrey, size: 20),
      title: Text(name),
      subtitle: Text(desc, style: const TextStyle(fontSize: 11)),
      dense: true,
      onTap: () {}, // Efecto visual
    );
  }
}