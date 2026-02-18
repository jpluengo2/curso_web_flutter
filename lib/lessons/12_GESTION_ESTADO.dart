import 'package:flutter/material.dart';
import 'package:provider/provider.dart';       // Librería Real
import 'package:flutter_bloc/flutter_bloc.dart'; // Librería Real
import 'package:equatable/equatable.dart';     // Librería Real

class Lab12GestionEstado extends StatelessWidget {
  const Lab12GestionEstado({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 12: Gestión de Estado Profesional",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        const Text(
          "Este laboratorio utiliza las librerías REALES 'provider' y 'flutter_bloc'.",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.green),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // --- 1. PROVIDER ---
        _buildSectionHeader("1. Provider (El Estándar Oficial)"),
        const Text("Gestión de un carrito de compras usando ChangeNotifierProvider y Consumer."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Carrito de Compras con Provider",
          const ProviderCartExample(),
        ),

        const SizedBox(height: 30),

        // --- 2. BLOC / CUBIT ---
        _buildSectionHeader("2. BLoC / Cubit (Arquitectura Limpia)"),
        const Text("Gestión de autenticación simulada separando totalmente la lógica de la UI."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Autenticación con Cubit",
          const BlocAuthExample(),
        ),

        const SizedBox(height: 30),

        // --- 3. VALUE NOTIFIER (NATIVO) ---
        _buildSectionHeader("3. ValueNotifier (Nativo/Reactivo)"),
        const Text("La alternativa ligera sin librerías externas para estados simples."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Controlador de Tema Nativo",
          const NativeNotifierExample(),
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

// ==================================================================
// EJEMPLO 1: PROVIDER (Real Implementation)
// ==================================================================

// 1.A. El Modelo (Lógica)
class CartModel extends ChangeNotifier {
  final List<String> _items = [];
  
  List<String> get items => _items;
  int get count => _items.length;

  void addItem(String item) {
    _items.add(item);
    notifyListeners(); // ¡Avisa a los widgets que repinten!
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// 1.B. La UI (Widget)
class ProviderCartExample extends StatelessWidget {
  const ProviderCartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el Provider SOLO en este trozo del árbol
    return ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Consumer<CartModel>(
                  builder: (context, cart, child) {
                    return Text(
                      "Items en carrito: ${cart.count}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    );
                  },
                ),
              ),
              // Botón para limpiar
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => context.read<CartModel>().clear(),
                  tooltip: "Vaciar",
                );
              })
            ],
          ),
          const Divider(),
          SizedBox(
            height: 150,
            child: Consumer<CartModel>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Center(child: Text("Carrito vacío", style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.shopping_bag, size: 18),
                    title: Text(cart.items[index]),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // Botones para añadir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AddButton(item: "Pizza 🍕"),
              _AddButton(item: "Hamburguesa 🍔"),
              _AddButton(item: "Refresco 🥤"),
            ],
          )
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String item;
  const _AddButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Accedemos al provider sin escuchar cambios (read) para ejecutar funciones
        Provider.of<CartModel>(context, listen: false).addItem(item);
      },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
      child: Text(item, style: const TextStyle(fontSize: 12)),
    );
  }
}


// ==================================================================
// EJEMPLO 2: FLUTTER_BLOC / CUBIT (Real Implementation)
// ==================================================================

// 2.A. Estado (State)
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String username;
  const AuthAuthenticated(this.username);
  @override
  List<Object> get props => [username];
}
class AuthUnauthenticated extends AuthState {}

// 2.B. Cubit (Logic)
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String username) async {
    emit(AuthLoading()); // Emitimos estado de carga
    await Future.delayed(const Duration(seconds: 2)); // Simulamos API
    
    if (username.isNotEmpty) {
      emit(AuthAuthenticated(username));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void logout() {
    emit(AuthLoading());
    // Simulamos un logout rápido
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(AuthInitial());
    });
  }
}

// 2.C. UI
class BlocAuthExample extends StatelessWidget {
  const BlocAuthExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el BlocProvider
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();
  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  final _userCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BlocBuilder reconstruye la UI según el estado
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            
            if (state is AuthLoading) {
              return const SizedBox(
                height: 100, 
                child: Center(child: CircularProgressIndicator())
              );
            }

            if (state is AuthAuthenticated) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 10),
                    Text("Bienvenido, ${state.username}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Cerrar Sesión"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => context.read<AuthCubit>().logout(),
                    )
                  ],
                ),
              );
            }

            // Estado Inicial o Error
            return Column(
              children: [
                if (state is AuthUnauthenticated)
                  const Text("Error: Usuario inválido", style: TextStyle(color: Colors.red)),
                
                const SizedBox(height: 10),
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: "Usuario", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.read<AuthCubit>().login(_userCtrl.text),
                  child: const Text("Iniciar Sesión (BLoC)"),
                )
              ],
            );
          },
        ),
      ],
    );
  }
}

// ==================================================================
// EJEMPLO 3: VALUE NOTIFIER (Nativo)
// ==================================================================
class NativeNotifierExample extends StatefulWidget {
  const NativeNotifierExample({super.key});
  @override
  State<NativeNotifierExample> createState() => _NativeNotifierExampleState();
}

class _NativeNotifierExampleState extends State<NativeNotifierExample> {
  // Un "mini-gestor" de estado nativo para valores simples
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(1.0);

  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Mueve el slider para cambiar la opacidad sin reconstruir toda la tarjeta."),
        const SizedBox(height: 10),
        
        // Solo este widget se reconstruye al cambiar el valor
        ValueListenableBuilder<double>(
          valueListenable: _opacityNotifier,
          builder: (context, value, child) {
            return AnimatedOpacity(
              opacity: value,
              duration: const Duration(milliseconds: 100),
              child: Container(
                height: 100,
                width: 100,
                color: Colors.purple,
                child: const Center(child: Icon(Icons.diamond, color: Colors.white, size: 40)),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        Slider(
          value: _opacityNotifier.value, 
          min: 0.0, max: 1.0,
          onChanged: (v) {
             // Esto actualiza el ValueNotifier, pero NO llama a setState
             // por lo que el slider mismo no se mueve fluido si no usas setState, 
             // pero el cuadro de arriba sí reacciona reactivamente.
             setState(() => _opacityNotifier.value = v);
          },
        )
      ],
    );
  }
}