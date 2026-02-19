import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Librería Real
import 'package:dio/dio.dart';           // Librería Real

class Lab14ConsumoApis extends StatelessWidget {
  const Lab14ConsumoApis({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 14: Consumo de APIs REST", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        const Card(
          color: Colors.greenAccent,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("✅ CONEXIÓN REAL: Estos ejemplos conectan a 'jsonplaceholder.typicode.com'.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),

        // --- 3. HTTP BÁSICO ---
        _buildSectionHeader("3. HTTP Básico (GET)"),
        const Text("Petición simple para obtener una lista de datos."),
        const SizedBox(height: 10),
        _buildExampleCard("Lista de Usuarios (http.get)", const HttpGetDemo()),
        const SizedBox(height: 30),

        // --- 4. DIO AVANZADO ---
        _buildSectionHeader("4. Dio (Cliente Avanzado)"),
        const Text("Uso de Dio para peticiones con configuración global."),
        const SizedBox(height: 10),
        _buildExampleCard("Petición con Dio", const DioGetDemo()),
        const SizedBox(height: 30),

        // --- 6. MANEJO DE ERRORES ---
        _buildSectionHeader("6. Manejo de Errores"),
        const Text("Simulación de errores (404, Sin conexión) y Try-Catch."),
        const SizedBox(height: 10),
        _buildExampleCard("Control de Excepciones", const ErrorHandlingDemo()),
        const SizedBox(height: 30),

        // --- 7. AUTENTICACIÓN Y POST ---
        _buildSectionHeader("7. Autenticación y POST"),
        const Text("Envío de datos al servidor (Crear recurso)."),
        const SizedBox(height: 10),
        _buildExampleCard("Crear Post (http.post)", const HttpPostDemo()),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. HTTP GET DEMO
class HttpGetDemo extends StatefulWidget {
  const HttpGetDemo({super.key});
  @override
  State<HttpGetDemo> createState() => _HttpGetDemoState();
}
class _HttpGetDemoState extends State<HttpGetDemo> {
  List<dynamic> _users = [];
  bool _loading = false;

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (response.statusCode == 200) {
        setState(() => _users = json.decode(response.body));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_users.isNotEmpty) 
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                leading: CircleAvatar(child: Text(_users[i]['name'][0])),
                title: Text(_users[i]['name']),
                subtitle: Text(_users[i]['email']),
              ),
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _loading ? null : _fetchUsers, child: _loading ? const CircularProgressIndicator() : const Text("Cargar Usuarios"))
      ],
    );
  }
}

// 2. DIO GET DEMO
class DioGetDemo extends StatefulWidget {
  const DioGetDemo({super.key});
  @override
  State<DioGetDemo> createState() => _DioGetDemoState();
}
class _DioGetDemoState extends State<DioGetDemo> {
  String _data = "Sin datos";
  final _dio = Dio();

  Future<void> _fetchDio() async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts/1');
      setState(() => _data = response.data['title']);
    } catch (e) {
      setState(() => _data = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text("Título Post 1:", style: const TextStyle(fontWeight: FontWeight.bold)), Text(_data), const SizedBox(height: 10), ElevatedButton(onPressed: _fetchDio, child: const Text("Petición con Dio"))]);
  }
}

// 3. ERROR HANDLING
class ErrorHandlingDemo extends StatefulWidget {
  const ErrorHandlingDemo({super.key});
  @override
  State<ErrorHandlingDemo> createState() => _ErrorHandlingDemoState();
}
class _ErrorHandlingDemoState extends State<ErrorHandlingDemo> {
  String _status = "";

  Future<void> _forceError() async {
    setState(() => _status = "Conectando...");
    try {
      // URL que no existe
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/bad_endpoint'));
      if (response.statusCode == 404) throw Exception("Error 404: Recurso no encontrado");
    } catch (e) {
      setState(() => _status = "❌ Capturado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(_status, style: const TextStyle(color: Colors.red)), ElevatedButton(onPressed: _forceError, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100), child: const Text("Forzar Error 404"))]);
  }
}

// 4. HTTP POST
class HttpPostDemo extends StatefulWidget {
  const HttpPostDemo({super.key});
  @override
  State<HttpPostDemo> createState() => _HttpPostDemoState();
}
class _HttpPostDemoState extends State<HttpPostDemo> {
  final _ctrl = TextEditingController();
  String _response = "";

  Future<void> _createPost() async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      body: jsonEncode({'title': _ctrl.text, 'body': 'Contenido', 'userId': 1}),
      headers: {'Content-type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 201) {
      setState(() => _response = "✅ Creado ID: ${jsonDecode(response.body)['id']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [TextField(controller: _ctrl, decoration: const InputDecoration(labelText: "Título del Post", isDense: true)), const SizedBox(height: 10), ElevatedButton(onPressed: _createPost, child: const Text("Enviar POST")), Text(_response, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]);
  }
}