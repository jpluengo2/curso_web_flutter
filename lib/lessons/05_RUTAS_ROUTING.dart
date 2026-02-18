import 'package:flutter/material.dart';

class Lab05Rutas extends StatelessWidget {
  const Lab05Rutas({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 05: Navegación y Rutas",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        const Text(
          "NOTA: Estos ejemplos usan un 'Navigator' aislado para no tapar la aplicación principal del cuaderno.",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 15),

        // --- 1. NAVEGACIÓN BÁSICA ---
        _buildSectionHeader("1. Navegación Básica (Named Routes)"),
        _buildExampleCard(
          "Simulador de Navigator con Rutas Nombradas",
          const SizedBox(
            height: 300,
            child: MiniNavigatorApp(),
          ),
        ),

        const SizedBox(height: 30),

        // --- 2. PASO DE ARGUMENTOS ---
        _buildSectionHeader("2. Paso de Argumentos"),
        _buildExampleCard(
          "Enviar datos hacia adelante",
          const SizedBox(
            height: 300,
            child: ArgumentsSimulator(),
          ),
        ),

        const SizedBox(height: 30),

        // --- 3. RETORNAR DATOS (NUEVO) ---
        _buildSectionHeader("3. Retornar Datos (await push)"),
        _buildExampleCard(
          "Recibir respuesta de la pantalla 2",
          const SizedBox(
            height: 300,
            child: ReturningDataSimulator(),
          ),
        ),

        const SizedBox(height: 30),

        // --- 4. TRANSICIONES (NUEVO) ---
        _buildSectionHeader("4. Transiciones Personalizadas"),
        _buildExampleCard(
          "Animaciones de Página (Slide/Fade)",
          const SizedBox(
            height: 300,
            child: TransitionSimulator(),
          ),
        ),

        const SizedBox(height: 30),

        // --- 5. BARRA DE NAVEGACIÓN ---
        _buildSectionHeader("5. Navegación con BottomBar"),
        _buildExampleCard(
          "Persistencia de estado con IndexedStack",
          const SizedBox(
            height: 350,
            child: BottomNavSimulator(),
          ),
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

// --- SIMULADORES DE NAVEGACIÓN ---

// 1. MINI NAVIGATOR
class MiniNavigatorApp extends StatelessWidget {
  const MiniNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (_) => const Screen1();
              break;
            case '/detail':
              builder = (_) => const Screen2();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
    );
  }
}

class Screen1 extends StatelessWidget {
  const Screen1({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(title: const Text("Pantalla 1"), automaticallyImplyLeading: false),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/detail'),
          child: const Text("Ir a Pantalla 2 ->"),
        ),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(title: const Text("Pantalla 2"), backgroundColor: Colors.green.shade100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("¡Has navegado con éxito!"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("<- Volver"),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. ARGUMENTS SIMULATOR
class ArgumentsSimulator extends StatefulWidget {
  const ArgumentsSimulator({super.key});
  @override
  State<ArgumentsSimulator> createState() => _ArgumentsSimulatorState();
}

class _ArgumentsSimulatorState extends State<ArgumentsSimulator> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
               if (settings.name == '/') {
                 return Scaffold(
                   appBar: AppBar(title: const Text("Tienda")),
                   body: ListView(
                     children: ["Laptop", "Teléfono", "Auriculares"].map((prod) => 
                       ListTile(
                         title: Text(prod),
                         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                         onTap: () => Navigator.pushNamed(context, '/details', arguments: prod),
                       )
                     ).toList(),
                   ),
                 );
               } else {
                 final args = settings.arguments as String;
                 return Scaffold(
                   backgroundColor: Colors.orange.shade50,
                   appBar: AppBar(title: const Text("Detalles"), backgroundColor: Colors.orange.shade100),
                   body: Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.shopping_bag, size: 50, color: Colors.orange.shade800),
                         Text("Producto: $args", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 20),
                         OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Volver"))
                       ],
                     ),
                   ),
                 );
               }
            },
            settings: settings,
          );
        },
      ),
    );
  }
}

// 3. RETURNING DATA SIMULATOR (NUEVO)
class ReturningDataSimulator extends StatelessWidget {
  const ReturningDataSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => const SelectionScreen(),
        ),
      ),
    );
  }
}

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String _result = "Ninguna selección";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selección")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Resultado: $_result", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateAndDisplaySelection(context),
              child: const Text("Seleccionar una opción"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push devuelve un Future que se completa cuando la ruta hace pop
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OptionsScreen()),
    );

    if (!mounted) return;
    
    // Cuando volvemos, actualizamos la UI con el resultado
    if (result != null) {
      setState(() => _result = result);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Seleccionaste: $result")));
    }
  }
}

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(title: const Text("Elige una opción"), backgroundColor: Colors.purple.shade100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'Opción A'),
              child: const Text("Opción A"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'Opción B'),
              child: const Text("Opción B"),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. TRANSITION SIMULATOR (NUEVO)
class TransitionSimulator extends StatelessWidget {
  const TransitionSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => const TransitionHome());
          }
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TransitionDetail(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Animación personalizada: Slide desde abajo
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
    );
  }
}

class TransitionHome extends StatelessWidget {
  const TransitionHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transiciones")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.arrow_upward),
          label: const Text("Slide Up Transition"),
          onPressed: () => Navigator.pushNamed(context, '/detail'),
        ),
      ),
    );
  }
}

class TransitionDetail extends StatelessWidget {
  const TransitionDetail({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(title: const Text("Detalle"), backgroundColor: Colors.teal.shade800),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text("¡Entrada animada!", style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal),
              child: const Text("Cerrar"),
            )
          ],
        ),
      ),
    );
  }
}

// 5. BOTTOM NAV SIMULATOR
class BottomNavSimulator extends StatefulWidget {
  const BottomNavSimulator({super.key});
  @override
  State<BottomNavSimulator> createState() => _BottomNavSimulatorState();
}

class _BottomNavSimulatorState extends State<BottomNavSimulator> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          Container(color: Colors.red.shade50, child: const Center(child: Text("Home", style: TextStyle(fontSize: 24)))),
          Container(color: Colors.blue.shade50, child: const Center(child: Text("Buscar", style: TextStyle(fontSize: 24)))),
          Container(color: Colors.purple.shade50, child: const Center(child: Text("Perfil", style: TextStyle(fontSize: 24)))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}