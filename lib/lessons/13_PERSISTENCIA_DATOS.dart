import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
// LIBRERÍAS REALES
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Lab13Persistencia extends StatelessWidget {
  const Lab13Persistencia({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 13: Persistencia de Datos Completa",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        const Card(
          color: Colors.amberAccent,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "NOTA: SharedPreferences, JSON y Encriptación (SecureStorage) ejecutan código REAL. SQLite, Hive, Isar y FileSystem son SIMULACIONES fieles para garantizar que la app funcione en Web sin configuraciones nativas complejas.",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // --- 2. SHAREDPREFERENCES ---
        _buildSectionHeader("2. SharedPreferences (Datos Simples)"),
        const Text("Almacenamiento Key-Value real para configuraciones."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Guardar Preferencias de Usuario",
          const RealSharedPreferencesDemo(),
        ),

        const SizedBox(height: 30),

        // --- 3. SQLITE ---
        _buildSectionHeader("3. SQLite (Datos Estructurados)"),
        const Text("Simulación de base de datos relacional (Tablas, Filas, SQL)."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Gestor SQL (CRUD Simulado)",
          const SqliteSimulation(),
        ),

        const SizedBox(height: 30),

        // --- 4. HIVE ---
        _buildSectionHeader("4. Hive (NoSQL Rápido)"),
        const Text("Simulación de cajas (Boxes) clave-valor de alto rendimiento."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Hive Box: Almacenamiento Rápido",
          const HiveSimulation(),
        ),

        const SizedBox(height: 30),

        // --- 5. ISAR ---
        _buildSectionHeader("5. Isar (NoSQL Moderno)"),
        const Text("Simulación de consultas complejas y filtros."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Filtros Isar: Búsqueda Avanzada",
          const IsarSimulation(),
        ),

        const SizedBox(height: 30),

        // --- 6. FILESYSTEM ---
        _buildSectionHeader("6. FileSystem (Archivos)"),
        const Text("Simulación de lectura y escritura de archivos de texto."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Editor de Archivos .txt",
          const FileSystemSimulation(),
        ),

        const SizedBox(height: 30),

        // --- 7. JSON ---
        _buildSectionHeader("7. JSON Serialization"),
        const Text("Serialización real de objetos Dart a formato JSON."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Parser JSON (Encode/Decode)",
          const JsonRealDemo(),
        ),

        const SizedBox(height: 30),

        // --- 8. ENCRIPTACIÓN ---
        _buildSectionHeader("8. Encriptación (Seguridad)"),
        const Text("Uso real de FlutterSecureStorage para guardar secretos."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Baúl Seguro (API Keys)",
          const RealSecureStorageDemo(),
        ),

        const SizedBox(height: 30),

        // --- 9. CACHÉ ---
        _buildSectionHeader("9. Estrategias de Caché"),
        const Text("Lógica para decidir si usar datos locales o de red."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Simulador de Caché con TTL",
          const CacheStrategyDemo(),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Padding(padding: const EdgeInsets.all(15), child: content),
        ],
      ),
    );
  }
}

// ==========================================
// 2. SHARED PREFERENCES (REAL)
// ==========================================
class RealSharedPreferencesDemo extends StatefulWidget {
  const RealSharedPreferencesDemo({super.key});
  @override
  State<RealSharedPreferencesDemo> createState() => _RealSharedPreferencesDemoState();
}

class _RealSharedPreferencesDemoState extends State<RealSharedPreferencesDemo> {
  bool _notifications = false;
  String _username = "";
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? false;
      _username = prefs.getString('username') ?? "";
      _ctrl.text = _username;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notifications);
    await prefs.setString('username', _ctrl.text);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guardado en Disco")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Recibir Notificaciones"),
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
        ),
        TextField(
          controller: _ctrl,
          decoration: const InputDecoration(labelText: "Nombre de Usuario", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _savePrefs,
          icon: const Icon(Icons.save),
          label: const Text("Persistir Configuración"),
        )
      ],
    );
  }
}

// ==========================================
// 3. SQLITE (SIMULADO)
// ==========================================
class SqliteSimulation extends StatefulWidget {
  const SqliteSimulation({super.key});
  @override
  State<SqliteSimulation> createState() => _SqliteSimulationState();
}

class _SqliteSimulationState extends State<SqliteSimulation> {
  // Simulación de Tabla
  final List<Map<String, dynamic>> _table = [
    {"id": 1, "task": "Comprar leche", "done": 0},
    {"id": 2, "task": "Estudiar SQL", "done": 1},
  ];
  final _ctrl = TextEditingController();

  void _insert() {
    if (_ctrl.text.isEmpty) return;
    setState(() {
      _table.add({
        "id": _table.length + 1,
        "task": _ctrl.text,
        "done": 0
      });
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tabla 'TASKS' (Relacional):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Container(
          height: 120,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
          child: ListView.builder(
            itemCount: _table.length,
            itemBuilder: (ctx, i) => ListTile(
              dense: true,
              leading: Text("${_table[i]['id']}"),
              title: Text(_table[i]['task']),
              trailing: Checkbox(value: _table[i]['done'] == 1, onChanged: (v) => setState(() => _table[i]['done'] = v! ? 1 : 0)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: "INSERT INTO tasks...", isDense: true))),
            IconButton(onPressed: _insert, icon: const Icon(Icons.send, color: Colors.blue)),
          ],
        )
      ],
    );
  }
}

// ==========================================
// 4. HIVE (SIMULADO)
// ==========================================
class HiveSimulation extends StatefulWidget {
  const HiveSimulation({super.key});
  @override
  State<HiveSimulation> createState() => _HiveSimulationState();
}

class _HiveSimulationState extends State<HiveSimulation> {
  // Hive usa "Boxes" (Cajas) no tablas
  final Map<dynamic, dynamic> _box = {
    "theme": "dark",
    "last_login": "2023-10-20"
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
          title: Text("Hive Box 'settings'"),
          subtitle: Text("Almacenamiento NoSQL rápido clave-valor"),
          leading: Icon(Icons.inbox, color: Colors.amber),
        ),
        Wrap(
          spacing: 10,
          children: _box.entries.map((e) => Chip(
            label: Text("${e.key}: ${e.value}"),
            onDeleted: () => setState(() => _box.remove(e.key)),
          )).toList(),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => setState(() => _box["new_key_${DateTime.now().second}"] = "value"),
          child: const Text("box.put('key', 'val')"),
        )
      ],
    );
  }
}

// ==========================================
// 5. ISAR (SIMULADO)
// ==========================================
class IsarSimulation extends StatefulWidget {
  const IsarSimulation({super.key});
  @override
  State<IsarSimulation> createState() => _IsarSimulationState();
}

class _IsarSimulationState extends State<IsarSimulation> {
  // Isar permite queries complejas
  final List<String> _users = ["Ana (25)", "Pedro (30)", "Luis (18)", "Maria (22)"];
  String _filter = "";

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) => u.toLowerCase().contains(_filter.toLowerCase())).toList();
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: "Query Isar: .filter().nameContains()", prefixIcon: Icon(Icons.search)),
          onChanged: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: 10),
        ...filtered.map((u) => Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Padding(padding: const EdgeInsets.all(8.0), child: Text(u)),
        ))
      ],
    );
  }
}

// ==========================================
// 6. FILESYSTEM (SIMULADO)
// ==========================================
class FileSystemSimulation extends StatefulWidget {
  const FileSystemSimulation({super.key});
  @override
  State<FileSystemSimulation> createState() => _FileSystemSimulationState();
}

class _FileSystemSimulationState extends State<FileSystemSimulation> {
  String _fileContent = "Contenido inicial del archivo...";
  final _ctrl = TextEditingController();

  void _writeFile() {
    setState(() => _fileContent = _ctrl.text);
    _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File.writeAsString() ejecutado")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: Colors.grey.shade200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📄 data.txt", style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              Text(_fileContent, style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(labelText: "Escribir en archivo"))),
            IconButton(icon: const Icon(Icons.save), onPressed: _writeFile),
          ],
        )
      ],
    );
  }
}

// ==========================================
// 7. JSON (REAL)
// ==========================================
class JsonRealDemo extends StatelessWidget {
  const JsonRealDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Objeto Dart
    final Map<String, dynamic> user = {
      "id": 101,
      "name": "Flutter Dev",
      "skills": ["Dart", "Widgets", "State"],
      "isActive": true
    };

    // 2. Encode
    final String jsonString = jsonEncode(user);

    // 3. Decode
    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("1. Objeto Dart Original:", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(user.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 10),
        const Text("2. JSON Encode (String para API/Disco):", style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.black,
          child: Text(jsonString, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12)),
        ),
        const SizedBox(height: 10),
        const Text("3. JSON Decode (Vuelta a Dart):", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Nombre: ${decoded['name']}", style: const TextStyle(color: Colors.blue)),
      ],
    );
  }
}

// ==========================================
// 8. ENCRIPTACIÓN (REAL - SecureStorage)
// ==========================================
class RealSecureStorageDemo extends StatefulWidget {
  const RealSecureStorageDemo({super.key});
  @override
  State<RealSecureStorageDemo> createState() => _RealSecureStorageDemoState();
}

class _RealSecureStorageDemoState extends State<RealSecureStorageDemo> {
  final _storage = const FlutterSecureStorage();
  String _secret = "???";
  final _ctrl = TextEditingController();

  Future<void> _write() async {
    await _storage.write(key: 'api_key', value: _ctrl.text);
    _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Encriptado y Guardado")));
  }

  Future<void> _read() async {
    final val = await _storage.read(key: 'api_key');
    setState(() => _secret = val ?? "No encontrado");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _ctrl, obscureText: true, decoration: const InputDecoration(labelText: "API Key Secreta")),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: _write, child: const Text("Encriptar")),
            OutlinedButton(onPressed: _read, child: const Text("Leer Desencriptado")),
          ],
        ),
        const SizedBox(height: 10),
        Text("Valor: $_secret", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      ],
    );
  }
}

// ==========================================
// 9. CACHÉ STRATEGY (SIMULADO)
// ==========================================
class CacheStrategyDemo extends StatefulWidget {
  const CacheStrategyDemo({super.key});
  @override
  State<CacheStrategyDemo> createState() => _CacheStrategyDemoState();
}

class _CacheStrategyDemoState extends State<CacheStrategyDemo> {
  String _data = "Sin datos";
  String _source = "";
  DateTime? _lastFetch;

  Future<void> _fetchData() async {
    setState(() => _source = "Comprobando...");
    
    // Lógica de Caché TTL (Time To Live) - 10 segundos
    if (_lastFetch != null && DateTime.now().difference(_lastFetch!).inSeconds < 10) {
      setState(() {
        _source = "📦 MEMORIA CACHÉ (Rápido)";
        _data = "Datos cacheados (${_lastFetch.toString().split(' ').last})";
      });
      return;
    }

    // Simular Red
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _lastFetch = DateTime.now();
      _source = "🌐 RED (Lento)";
      _data = "Datos frescos de internet";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(_data),
          subtitle: Text(_source, style: TextStyle(color: _source.contains("RED") ? Colors.blue : Colors.orange, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.cloud_download),
        ),
        ElevatedButton(onPressed: _fetchData, child: const Text("Pedir Datos (TTL 10s)"))
      ],
    );
  }
}