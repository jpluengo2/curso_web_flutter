import 'package:flutter/material.dart';

class Lab29GestionDependencias extends StatelessWidget {
  const Lab29GestionDependencias({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 29: Gestión de Dependencias", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        const Text("Aprende a interpretar el archivo pubspec.yaml y el versionado semántico.", textAlign: TextAlign.center),
        const SizedBox(height: 20),

        _buildSectionHeader("1. Versionado Semántico"),
        _buildExampleCard("Simulador de Versiones (^)", const VersioningSimulator()),
        
        const SizedBox(height: 30),
        _buildSectionHeader("2. Comandos Pub"),
        _buildExampleCard("Toolbox de Comandos", const PubCommandsList()),
        
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. VERSIONING SIMULATOR
class VersioningSimulator extends StatefulWidget {
  const VersioningSimulator({super.key});
  @override
  State<VersioningSimulator> createState() => _VersioningSimulatorState();
}
class _VersioningSimulatorState extends State<VersioningSimulator> {
  String _caret = "^1.2.3";
  String _explanation = "Permite actualizaciones compatibles hacia atrás (1.2.3 hasta <2.0.0)";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Selecciona una sintaxis de versión:", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            _btn("^1.2.3", "Caret: Actualiza minors y patches (1.3.0, 1.2.4) pero NO 2.0.0"),
            _btn("1.2.3", "Exacta: Solo instala exactamente la 1.2.3"),
            _btn("any", "Peligro: Instala cualquier versión (No recomendado)"),
          ],
        ),
        const Divider(),
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Text(_caret, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 5),
              Text(_explanation, textAlign: TextAlign.center),
            ],
          ),
        )
      ],
    );
  }

  Widget _btn(String label, String desc) {
    return ChoiceChip(
      label: Text(label),
      selected: _caret == label,
      onSelected: (v) => setState(() { _caret = label; _explanation = desc; }),
    );
  }
}

// 2. PUB COMMANDS
class PubCommandsList extends StatelessWidget {
  const PubCommandsList({super.key});

  @override
  Widget build(BuildContext context) {
    final cmds = [
      {"cmd": "flutter pub get", "desc": "Descarga las dependencias listadas."},
      {"cmd": "flutter pub upgrade", "desc": "Actualiza a las últimas versiones permitidas."},
      {"cmd": "flutter pub outdated", "desc": "Muestra qué paquetes tienen versiones nuevas."},
      {"cmd": "flutter pub add [pkg]", "desc": "Añade un paquete automáticamente."},
    ];

    return Column(
      children: cmds.map((c) => ListTile(
        leading: const Icon(Icons.terminal, color: Colors.black87),
        title: Text(c['cmd']!, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        subtitle: Text(c['desc']!),
      )).toList(),
    );
  }
}