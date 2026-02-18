import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Lab23DeviceAccess extends StatelessWidget {
  const Lab23DeviceAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 23: Acceso al Dispositivo", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        const Card(
          color: Colors.orangeAccent,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("⚠️ MODO SIMULACIÓN: Al estar en Web, simulamos el hardware (Cámara, GPS, Sensores) para enseñar la lógica sin requerir un dispositivo físico.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
          ),
        ),
        const SizedBox(height: 20),

        // --- 1. PERMISOS ---
        _buildSectionHeader("1. Gestión de Permisos"),
        const Text("Simulación del flujo de solicitud y denegación de permisos."),
        const SizedBox(height: 10),
        _buildExampleCard("Solicitud de Permisos", const PermissionSimulator()),
        const SizedBox(height: 30),

        // --- 2. CÁMARA ---
        _buildSectionHeader("2. Cámara e Imágenes"),
        const Text("Simulador de ImagePicker y visualización."),
        const SizedBox(height: 10),
        _buildExampleCard("Cámara Virtual", const CameraSimulator()),
        const SizedBox(height: 30),

        // --- 3. UBICACIÓN ---
        _buildSectionHeader("3. Geolocalización (GPS)"),
        const Text("Simulación de coordenadas y cálculo de distancia."),
        const SizedBox(height: 10),
        _buildExampleCard("Monitor GPS", const LocationSimulator()),
        const SizedBox(height: 30),

        // --- 4. SENSORES ---
        _buildSectionHeader("4. Sensores (Acelerómetro)"),
        const Text("Detección de movimiento simulado."),
        const SizedBox(height: 10),
        _buildExampleCard("Sensor de Movimiento", const SensorSimulator()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. PERMISSION SIMULATOR
class PermissionSimulator extends StatefulWidget {
  const PermissionSimulator({super.key});
  @override
  State<PermissionSimulator> createState() => _PermissionSimulatorState();
}
class _PermissionSimulatorState extends State<PermissionSimulator> {
  Map<String, String> _permissions = {
    "Cámara": "Desconocido",
    "Ubicación": "Desconocido",
    "Micrófono": "Denegado"
  };

  void _request(String type) async {
    setState(() => _permissions[type] = "Solicitando...");
    await Future.delayed(const Duration(seconds: 1));
    // Simula respuesta del usuario (Random)
    bool granted = Random().nextBool();
    if (mounted) setState(() => _permissions[type] = granted ? "Concedido ✅" : "Denegado ❌");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _permissions.entries.map((e) => ListTile(
        title: Text(e.key),
        subtitle: Text(e.value, style: TextStyle(color: e.value.contains("Concedido") ? Colors.green : (e.value.contains("Denegado") ? Colors.red : Colors.orange))),
        trailing: ElevatedButton(onPressed: () => _request(e.key), child: const Text("Pedir")),
      )).toList(),
    );
  }
}

// 2. CAMERA SIMULATOR
class CameraSimulator extends StatefulWidget {
  const CameraSimulator({super.key});
  @override
  State<CameraSimulator> createState() => _CameraSimulatorState();
}
class _CameraSimulatorState extends State<CameraSimulator> {
  bool _hasPhoto = false;
  bool _loading = false;

  void _takePhoto() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Shutter lag
    setState(() { _hasPhoto = true; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 150, width: double.infinity,
        color: Colors.black87,
        child: _hasPhoto 
          ? const Center(child: Icon(Icons.image, size: 80, color: Colors.white))
          : const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey)),
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton.icon(onPressed: _loading ? null : _takePhoto, icon: const Icon(Icons.camera), label: const Text("Tomar Foto")),
        if (_hasPhoto) TextButton(onPressed: () => setState(() => _hasPhoto = false), child: const Text("Borrar", style: TextStyle(color: Colors.red)))
      ])
    ]);
  }
}

// 3. LOCATION SIMULATOR
class LocationSimulator extends StatefulWidget {
  const LocationSimulator({super.key});
  @override
  State<LocationSimulator> createState() => _LocationSimulatorState();
}
class _LocationSimulatorState extends State<LocationSimulator> {
  String _coords = "Esperando señal GPS...";
  
  void _getLocation() async {
    setState(() => _coords = "Triangulando satélites...");
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _coords = "Lat: 40.416${Random().nextInt(9)}\nLng: -3.703${Random().nextInt(9)}");
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.satellite_alt, size: 40, color: Colors.blue),
      title: Text(_coords, style: const TextStyle(fontFamily: 'monospace')),
      trailing: IconButton.filled(onPressed: _getLocation, icon: const Icon(Icons.my_location)),
    );
  }
}

// 4. SENSOR SIMULATOR
class SensorSimulator extends StatefulWidget {
  const SensorSimulator({super.key});
  @override
  State<SensorSimulator> createState() => _SensorSimulatorState();
}
class _SensorSimulatorState extends State<SensorSimulator> {
  double _x = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Simular Acelerómetro (Mover slider)"),
        Slider(value: _x, min: -10, max: 10, onChanged: (v) => setState(() => _x = v)),
        Transform.rotate(
          angle: _x * (pi / 180) * 5, // Rotar visualmente
          child: const Icon(Icons.phone_iphone, size: 80, color: Colors.indigo),
        ),
        Text("Inclinación X: ${_x.toStringAsFixed(2)}"),
      ],
    );
  }
}
