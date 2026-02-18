import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Lab03AdvancedBuilders extends StatelessWidget {
  const Lab03AdvancedBuilders({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 03: Builders, Futures y Streams",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. BUILDER (CONTEXTO) ---
        _buildSectionHeader("1. El Widget Builder"),
        const Text("Uso de Builder para obtener un contexto hijo válido."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Solución a errores de Contexto",
          const ContextFixerDemo(),
        ),

        const SizedBox(height: 30),

        // --- 2. EJERCICIO 1: LISTA USUARIOS (FUTURE) ---
        _buildSectionHeader("2. FutureBuilder: Consumo de API"),
        const Text("Ejercicio 1: Carga asíncrona de una lista de usuarios con estados (Carga, Error, Datos)."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Simulación de API REST",
          const UserListLoader(),
        ),

        const SizedBox(height: 30),

        // --- 3. EJERCICIO 2: CHAT (STREAM) ---
        _buildSectionHeader("3. StreamBuilder: Chat en Vivo"),
        const Text("Ejercicio 2: Simulación de mensajes entrantes en tiempo real."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Chat Bot Simulado",
          const StreamChatSimulator(),
        ),

        const SizedBox(height: 30),

        // --- 4. EJERCICIO 3: VALIDACIÓN REACTIVA ---
        _buildSectionHeader("4. ValueListenable: Optimización"),
        const Text("Ejercicio 3: Validar formularios sin reconstruir toda la pantalla (sin setState)."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Login Reactivo Optimizado",
          const ReactiveLogin(),
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
// WIDGETS DE EJEMPLO
// ==========================================

// 1. CONTEXT FIXER (BUILDER)
class ContextFixerDemo extends StatelessWidget {
  const ContextFixerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Si intentas usar Scaffold.of() aquí directamente, fallaría porque el contexto es el del padre.", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 10),
        // Builder crea un contexto nuevo DEBAJO del widget actual
        Builder(
          builder: (childContext) {
            return ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Mostrar SnackBar (Con Builder)"),
              onPressed: () {
                // Usamos childContext, que sí 've' este sub-árbol
                ScaffoldMessenger.of(childContext).showSnackBar(
                  const SnackBar(content: Text("¡Contexto encontrado correctamente!")),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// 2. USER LIST LOADER (Ejercicio 1 - API Simulation)
class UserListLoader extends StatefulWidget {
  const UserListLoader({super.key});
  @override
  State<UserListLoader> createState() => _UserListLoaderState();
}

class _UserListLoaderState extends State<UserListLoader> {
  // Simula una petición HTTP que puede fallar
  Future<List<String>> _fetchUsers() async {
    await Future.delayed(const Duration(seconds: 2)); // Latencia
    
    // Simular error aleatorio (20% prob)
    if (Random().nextInt(10) > 7) {
      throw Exception("Error 500: Servidor no responde");
    }

    return [
      "Ana García (Dev)",
      "Carlos Ruiz (Product)",
      "Elena Nito (Design)",
      "Zacarias Flores (QA)",
      "Juan Nadie (Manager)"
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: FutureBuilder<List<String>>(
            future: _fetchUsers(),
            builder: (context, snapshot) {
              // 1. Estado de Carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Conectando con API..."),
                  ],
                ));
              }

              // 2. Estado de Error
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: Colors.red),
                      Text("Error: ${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 5),
                      ElevatedButton(onPressed: () => setState(() {}), child: const Text("Reintentar"))
                    ],
                  ),
                );
              }

              // 3. Estado de Datos (Éxito)
              final users = snapshot.data ?? [];
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) => ListTile(
                  leading: CircleAvatar(child: Text(users[index][0])),
                  title: Text(users[index]),
                  dense: true,
                ),
              );
            },
          ),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: () => setState(() {}), 
          child: const Text("Recargar Lista"),
        )
      ],
    );
  }
}

// 3. STREAM CHAT SIMULATOR (Ejercicio 2)
class StreamChatSimulator extends StatefulWidget {
  const StreamChatSimulator({super.key});
  @override
  State<StreamChatSimulator> createState() => _StreamChatSimulatorState();
}

class _StreamChatSimulatorState extends State<StreamChatSimulator> {
  final StreamController<List<String>> _chatController = StreamController<List<String>>();
  final List<String> _messages = [];
  Timer? _botTimer;

  @override
  void initState() {
    super.initState();
    _startBot();
  }

  void _startBot() {
    // Simula mensajes llegando cada 1.5 segundos
    int counter = 0;
    final phrases = [
      "¡Hola! Bienvenido al curso.",
      "Flutter usa Dart.",
      "¿Has probado el Hot Reload?",
      "Los Streams son geniales.",
      "Recuerda usar dispose()."
    ];

    _botTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (counter < phrases.length) {
        _messages.add(phrases[counter]);
        _chatController.add(List.from(_messages.reversed)); // Nuevos arriba
        counter++;
      } else {
        timer.cancel();
      }
    });
  }

  void _reset() {
    _messages.clear();
    _chatController.add([]);
    _botTimer?.cancel();
    _startBot();
  }

  @override
  void dispose() {
    _chatController.close();
    _botTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100)
          ),
          child: StreamBuilder<List<String>>(
            stream: _chatController.stream,
            initialData: const [],
            builder: (context, snapshot) {
              final msgs = snapshot.data!;
              if (msgs.isEmpty) return const Center(child: Text("Esperando mensajes..."));

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]
                      ),
                      child: Text(msgs[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Reiniciar Chat"),
          onPressed: _reset,
        )
      ],
    );
  }
}

// 4. REACTIVE LOGIN (Ejercicio 3 - ValueListenable)
class ReactiveLogin extends StatefulWidget {
  const ReactiveLogin({super.key});
  @override
  State<ReactiveLogin> createState() => _ReactiveLoginState();
}

class _ReactiveLoginState extends State<ReactiveLogin> {
  // Notifiers: Guardan el estado sin necesitar setState para toda la pantalla
  final ValueNotifier<String> _emailNotifier = ValueNotifier("");
  final ValueNotifier<String> _passNotifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
          onChanged: (v) => _emailNotifier.value = v,
        ),
        const SizedBox(height: 10),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
          onChanged: (v) => _passNotifier.value = v,
        ),
        const SizedBox(height: 20),
        
        // ValueListenableBuilder 1: Mensaje de validación
        ValueListenableBuilder<String>(
          valueListenable: _passNotifier,
          builder: (context, pass, _) {
            final color = pass.length > 5 ? Colors.green : Colors.red;
            final text = pass.length > 5 ? "Contraseña Segura" : "Contraseña muy corta";
            return Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold));
          },
        ),
        const SizedBox(height: 10),

        // ValueListenableBuilder 2: Habilitar botón (Combina 2 notifiers)
        // Nota: Para combinar 2, normalmente haríamos un objeto, pero aquí anidamos para simplificar
        ValueListenableBuilder<String>(
          valueListenable: _emailNotifier,
          builder: (context, email, _) {
            return ValueListenableBuilder<String>(
              valueListenable: _passNotifier,
              builder: (context, pass, _) {
                final isValid = email.contains("@") && pass.length > 5;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid ? () {} : null, // Se deshabilita si no es válido
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? Colors.indigo : Colors.grey,
                      foregroundColor: Colors.white
                    ),
                    child: const Text("Ingresar (Reactivo)"),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}