import 'package:flutter/material.dart';

class Lab01FundamentosWidgets extends StatelessWidget {
  const Lab01FundamentosWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Título del Laboratorio
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio: Fundamentos y Widgets Básicos",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),

        // --- 1. ESTRUCTURA BÁSICA (Simulación Visual) ---
        _buildSectionHeader("1. Estructura Básica (App Bar + Center)"),
        _buildExampleCard(
          "Ejemplo 1.1: Hola Flutter",
          SizedBox(
            height: 200, // Limitamos altura para simular una pantalla
            child: Scaffold(
              appBar: AppBar(title: const Text('Hola Flutter'), backgroundColor: Colors.blue.shade100),
              body: const Center(child: Text('¡Bienvenido!')),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 2. STATELESS VS STATEFUL ---
        _buildSectionHeader("2. Stateless vs StatefulWidget"),
        
        _buildExampleCard(
          "Ejemplo 2.1: StatelessWidget (Inmutable)",
          const WelcomeWidget(),
        ),

        const SizedBox(height: 15),

        _buildExampleCard(
          "Ejemplo 2.2: StatefulWidget (Contador)",
          const CounterWidget(),
        ),

        const SizedBox(height: 30),

        // --- 3. WIDGETS DE TEXTO ---
        _buildSectionHeader("3. Widgets de Texto e Inputs"),
        
        _buildExampleCard(
          "Ejemplo 3.1: Variaciones de Texto",
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Texto simple'),
              SizedBox(height: 10),
              Text(
                'Texto con estilos (Bold, Azul)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 10),
              Text(
                'Texto largo con overflow ellipsis que se corta si es muy largo...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              Center(child: Text('Texto centrado con TextAlign.center')),
            ],
          ),
        ),

        const SizedBox(height: 15),

        _buildExampleCard(
          "Ejemplo 3.2: TextField (Entrada de datos)",
          const TextInputExample(),
        ),

        const SizedBox(height: 30),

        // --- 4. BOTONES ---
        _buildSectionHeader("4. Botones"),
        
        _buildExampleCard(
          "Ejemplo 4.1: Tipos de Botones",
          Column(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('ElevatedButton')),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.add, size: 18), 
                label: const Text('Con Icono')
              ),
              const SizedBox(height: 10),
              const ElevatedButton(onPressed: null, child: Text('Deshabilitado')),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: () {}, child: const Text('OutlinedButton')),
              const SizedBox(height: 10),
              TextButton(onPressed: () {}, child: const Text('TextButton')),
            ],
          ),
        ),
        
        const SizedBox(height: 15),

        _buildExampleCard(
          "Ejemplo 4.4: FloatingActionButton (Simulación)",
          SizedBox(
            height: 150,
            child: Scaffold(
              body: const Center(child: Text("Pantalla con FAB")),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                mini: true,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 5. LAYOUTS ---
        _buildSectionHeader("5. Widgets de Layout"),
        
        _buildExampleCard(
          "Ejemplo 5.1: Container (Caja Decorada)",
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
              ]
            ),
            child: const Text("Soy un Container con Borde, Sombra y Radius"),
          ),
        ),

        const SizedBox(height: 15),

        _buildExampleCard(
          "Ejemplo 5.3: Row (Fila Horizontal)",
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.home, color: Colors.blue),
              Icon(Icons.search, color: Colors.green),
              Icon(Icons.settings, color: Colors.red),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- 6. IMÁGENES ---
        _buildSectionHeader("6. Imágenes e Iconos"),
        
        _buildExampleCard(
          "Ejemplo 6.1: Imágenes (Network)",
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Column(
                 children: [
                   Icon(Icons.image, size: 50, color: Colors.grey),
                   SizedBox(height: 5),
                   Text("Asset (Simulado)", style: TextStyle(fontSize: 10)),
                 ],
               ),
               const SizedBox(width: 20),
               Image.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
               ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- 7. SCROLLS ---
        _buildSectionHeader("7. ListViews"),
        
        _buildExampleCard(
          "Ejemplo 7.1: ListView.builder",
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(child: Text("$index"), radius: 15),
                title: Text("Elemento de lista #$index"),
                subtitle: const Text("Subtítulo descriptivo"),
                dense: true,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // --- 8. EJEMPLO FINAL ---
        _buildSectionHeader("8. Mini App: Lista de Tareas"),
        _buildExampleCard(
          "Todo App (Funcional)",
          const SizedBox(
            height: 400, // Altura fija para la mini-app
            child: MiniTodoApp(),
          ),
        ),
        
        const SizedBox(height: 50), // Espacio final
      ],
    );
  }

  // --- WIDGETS AUXILIARES DE DISEÑO ---

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
          Padding(
            padding: const EdgeInsets.all(15),
            child: content,
          ),
        ],
      ),
    );
  }
}

// --- CLASES PRIVADAS (LÓGICA INTERNA DE LOS EJEMPLOS) ---

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text('Hola, soy un StatelessWidget Inmutable', style: TextStyle(fontSize: 16));
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Contador: $count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('+1'),
        ),
      ],
    );
  }
}

class TextInputExample extends StatefulWidget {
  const TextInputExample({super.key});
  @override
  State<TextInputExample> createState() => _TextInputExampleState();
}

class _TextInputExampleState extends State<TextInputExample> {
  String _text = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Escribe algo...",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit),
            isDense: true,
          ),
          onChanged: (val) => setState(() => _text = val),
        ),
        const SizedBox(height: 5),
        Text("Tu texto: $_text", style: const TextStyle(color: Colors.blue)),
      ],
    );
  }
}

class MiniTodoApp extends StatefulWidget {
  const MiniTodoApp({super.key});
  @override
  State<MiniTodoApp> createState() => _MiniTodoAppState();
}

class _MiniTodoAppState extends State<MiniTodoApp> {
  final List<String> tasks = ["Aprender Flutter", "Hacer ejercicio"];
  final TextEditingController _ctrl = TextEditingController();

  void _addTask() {
    if (_ctrl.text.isNotEmpty) {
      setState(() { tasks.add(_ctrl.text); _ctrl.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Tareas"), backgroundColor: Colors.indigo.shade50, automaticallyImplyLeading: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: "Nueva tarea", isDense: true, border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _addTask, icon: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_,__) => const Divider(height: 1),
              itemBuilder: (_, index) => ListTile(
                title: Text(tasks[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                  onPressed: () => setState(() => tasks.removeAt(index)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}