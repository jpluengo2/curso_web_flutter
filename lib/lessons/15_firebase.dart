import 'package:flutter/material.dart';
import 'dart:async';

class Lab15Firebase extends StatelessWidget {
  const Lab15Firebase({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 15: Firebase Ecosystem", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
        const Card(
          color: Colors.amberAccent,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("⚠️ SIMULACIÓN: Este laboratorio simula el comportamiento de Firebase (Auth y Firestore) para funcionar en Web sin necesidad de configurar un proyecto de Google Console real.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader("2. Authentication"),
        _buildExampleCard("Login con Email/Password (Simulado)", const FirebaseAuthSim()),
        const SizedBox(height: 30),

        _buildSectionHeader("3. Cloud Firestore"),
        _buildExampleCard("Lista de Tareas en Tiempo Real (Streams)", const FirestoreSim()),
        const SizedBox(height: 30),

        _buildSectionHeader("4. Storage"),
        _buildExampleCard("Subida de Archivos (Simulada)", const StorageSim()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. AUTH SIMULATOR
class FirebaseAuthSim extends StatefulWidget {
  const FirebaseAuthSim({super.key});
  @override
  State<FirebaseAuthSim> createState() => _FirebaseAuthSimState();
}
class _FirebaseAuthSimState extends State<FirebaseAuthSim> {
  bool _isLogged = false;
  bool _loading = false;
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // Network delay
    setState(() {
      _isLogged = true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLogged) {
      return Column(children: [
        const Icon(Icons.account_circle, size: 50, color: Colors.blue),
        Text("Bienvenido, ${_email.text}"),
        TextButton(onPressed: () => setState(() => _isLogged = false), child: const Text("Cerrar Sesión"))
      ]);
    }
    return Column(children: [
      TextField(controller: _email, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), isDense: true)),
      const SizedBox(height: 10),
      TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock), isDense: true)),
      const SizedBox(height: 10),
      ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text("Sign In"))
    ]);
  }
}

// 2. FIRESTORE SIMULATOR
class FirestoreSim extends StatefulWidget {
  const FirestoreSim({super.key});
  @override
  State<FirestoreSim> createState() => _FirestoreSimState();
}
class _FirestoreSimState extends State<FirestoreSim> {
  // Simula una colección de Firestore
  final StreamController<List<String>> _collectionStream = StreamController<List<String>>();
  final List<String> _docs = ["Comprar leche", "Ir al gym"];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emit();
  }
  
  void _emit() => _collectionStream.add(List.from(_docs));

  void _addDoc() {
    if (_ctrl.text.isNotEmpty) {
      _docs.add(_ctrl.text);
      _emit(); // En Firestore esto pasa automágicamente
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _collectionStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 150,
        child: StreamBuilder<List<String>>(
          stream: _collectionStream.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (_,__) => const Divider(height: 1),
              itemBuilder: (ctx, i) => ListTile(
                dense: true,
                leading: const Icon(Icons.article, color: Colors.orange),
                title: Text(snapshot.data![i]),
                trailing: IconButton(icon: const Icon(Icons.delete, size: 16), onPressed: () { _docs.removeAt(i); _emit(); }),
              ),
            );
          },
        ),
      ),
      Row(children: [Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: "Nuevo documento..."))), IconButton(icon: const Icon(Icons.send), onPressed: _addDoc)])
    ]);
  }
}

// 3. STORAGE SIMULATOR
class StorageSim extends StatefulWidget {
  const StorageSim({super.key});
  @override
  State<StorageSim> createState() => _StorageSimState();
}
class _StorageSimState extends State<StorageSim> {
  double _progress = 0.0;
  bool _uploading = false;

  void _upload() async {
    setState(() { _uploading = true; _progress = 0; });
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _progress = i / 10);
    }
    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
      if (_uploading) LinearProgressIndicator(value: _progress),
      if (!_uploading && _progress == 1.0) const Text("✅ Subida completada", style: TextStyle(color: Colors.green)),
      const SizedBox(height: 10),
      ElevatedButton(onPressed: _uploading ? null : _upload, child: const Text("Simular Subida de Imagen"))
    ]);
  }
}