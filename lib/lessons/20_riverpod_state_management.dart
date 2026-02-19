import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- DEFINICIÓN DE PROVIDERS (Globales, pero seguros con Riverpod) ---

// 1. Provider Simple (Solo lectura/Constante)
final greetingProvider = Provider<String>((ref) => "¡Hola desde Riverpod!");

// 2. StateProvider (Estado simple mutable - Contador)
final counterProvider = StateProvider<int>((ref) => 0);

// 3. NotifierProvider (Estado complejo - Lista de Tareas)
class TodoNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addTodo(String todo) => state = [...state, todo];
  void removeTodo(String todo) => state = state.where((item) => item != todo).toList();
}
final todoProvider = NotifierProvider<TodoNotifier, List<String>>(TodoNotifier.new);

// 4. FutureProvider (Asíncrono - Simulación API)
final weatherProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 2)); // Simular red
  return "24°C - Soleado ☀️";
});


class Lab20Riverpod extends StatelessWidget {
  const Lab20Riverpod({super.key});

  @override
  Widget build(BuildContext context) {
    // IMPORTANTE: ProviderScope necesario para que Riverpod funcione en esta vista
    return ProviderScope(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text("Laboratorio 20: Riverpod", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),

          // --- 1. PROVIDER BÁSICO ---
          _buildSectionHeader("1. Provider (Lectura Simple)"),
          _buildExampleCard("Lectura de datos estáticos", const BasicReader()),
          const SizedBox(height: 30),

          // --- 2. STATE PROVIDER ---
          _buildSectionHeader("2. StateProvider (Contador)"),
          const Text("Ideal para estados simples (int, bool, string)."),
          const SizedBox(height: 10),
          _buildExampleCard("Contador Reactivo", const CounterWidget()),
          const SizedBox(height: 30),

          // --- 3. NOTIFIER PROVIDER ---
          _buildSectionHeader("3. NotifierProvider (Lógica Compleja)"),
          const Text("Para manejar listas o estados compuestos con lógica de negocio."),
          const SizedBox(height: 10),
          _buildExampleCard("Lista de Tareas (Notifier)", const TodoListWidget()),
          const SizedBox(height: 30),

          // --- 4. FUTURE PROVIDER ---
          _buildSectionHeader("4. FutureProvider (Async)"),
          const Text("Maneja automáticamente los estados: loading, error y data."),
          const SizedBox(height: 10),
          _buildExampleCard("Clima Asíncrono", const WeatherWidget()),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. BASIC READER
class BasicReader extends ConsumerWidget {
  const BasicReader({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    return Center(child: Text(greeting, style: const TextStyle(fontSize: 18, color: Colors.indigo)));
  }
}

// 2. COUNTER WIDGET
class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.remove),
          onPressed: () => ref.read(counterProvider.notifier).state--,
        ),
        const SizedBox(width: 20),
        Text("$count", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        IconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: () => ref.read(counterProvider.notifier).state++,
        ),
      ],
    );
  }
}

// 3. TODO LIST WIDGET
class TodoListWidget extends ConsumerWidget {
  const TodoListWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text("Tareas: ${todos.length}", style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () => ref.read(todoProvider.notifier).addTodo("Tarea ${DateTime.now().second}"),
            )
          ],
        ),
        const Divider(),
        SizedBox(
          height: 150,
          child: todos.isEmpty 
            ? const Center(child: Text("Sin tareas"))
            : ListView.builder(
                itemCount: todos.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(todos[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => ref.read(todoProvider.notifier).removeTodo(todos[i]),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

// 4. WEATHER WIDGET (ASYNC)
class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeather = ref.watch(weatherProvider);

    return asyncWeather.when(
      data: (data) => Center(child: Column(children: [const Icon(Icons.wb_sunny, size: 40, color: Colors.orange), Text(data, style: const TextStyle(fontSize: 18))])),
      error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}