import 'package:flutter/material.dart';

class Lab22CleanArch extends StatelessWidget {
  const Lab22CleanArch({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 22: Clean Architecture", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        const Card(
          color: Colors.lightGreenAccent,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("🧠 ARQUITECTURA EN CAPAS: Este archivo contiene una implementación 'mini' completa de las 3 capas: Data, Domain y Presentation.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader("1. Estructura de Capas"),
        const Text("Simulación de cómo viaja un dato desde el DataSource hasta la UI."),
        const SizedBox(height: 10),
        _buildExampleCard("Feature: GetUser", const CleanArchFeatureDemo()),
        
        const SizedBox(height: 30),
        _buildSectionHeader("2. Diagrama de Clases (Código)"),
        const Text("Revisa el código fuente de este laboratorio para ver las clases:"),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.grey.shade100,
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("1. Domain: User (Entity) & UserRepository (Interface)", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("2. Data: UserDto (Model) & UserRepositoryImpl", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("3. Presentation: UserPage (UI)", style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
        )
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// =========================================================
// CAPA 1: DOMAIN (Reglas de Negocio - Puro Dart)
// =========================================================

// Entity: El objeto puro de negocio
class UserEntity {
  final int id;
  final String name;
  final String role;
  
  UserEntity({required this.id, required this.name, required this.role});
}

// Repository Interface: Contrato de lo que necesitamos
abstract class UserRepository {
  Future<UserEntity> getUser(int id);
}

// UseCase: Acción específica
class GetUserUseCase {
  final UserRepository repository;
  GetUserUseCase(this.repository);

  Future<UserEntity> call(int id) {
    return repository.getUser(id);
  }
}

// =========================================================
// CAPA 2: DATA (Implementación y Fuentes de Datos)
// =========================================================

// Model: Extensión de la entidad con métodos JSON (DTO)
class UserModel extends UserEntity {
  UserModel({required super.id, required super.name, required super.role});

  // Simulación de fromJson
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role']
    );
  }
}

// DataSource: Conexión con API/DB simulada
class UserRemoteDataSource {
  Future<UserModel> fetchUserFromApi(int id) async {
    await Future.delayed(const Duration(seconds: 1)); // Delay de red
    // Respuesta simulada de API
    return UserModel.fromJson({'id': id, 'name': 'Usuario Limpio $id', 'role': 'Architect'});
  }
}

// Repository Implementation: Une DataSource con Domain
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource dataSource;
  UserRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity> getUser(int id) async {
    final userModel = await dataSource.fetchUserFromApi(id);
    return userModel; // El modelo ES una entidad, así que cumple el contrato
  }
}

// =========================================================
// CAPA 3: PRESENTATION (UI)
// =========================================================

// Dependency Injection (Manual para el ejemplo)
final dataSource = UserRemoteDataSource();
final repository = UserRepositoryImpl(dataSource);
final useCase = GetUserUseCase(repository);

class CleanArchFeatureDemo extends StatefulWidget {
  const CleanArchFeatureDemo({super.key});
  @override
  State<CleanArchFeatureDemo> createState() => _CleanArchFeatureDemoState();
}

class _CleanArchFeatureDemoState extends State<CleanArchFeatureDemo> {
  UserEntity? _user;
  bool _loading = false;

  void _loadUser() async {
    setState(() => _loading = true);
    // La UI solo habla con el Caso de Uso, no sabe de APIs ni JSONs
    final user = await useCase.call(101); 
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_loading) const CircularProgressIndicator(),
        if (_user != null && !_loading) 
          ListTile(
            leading: CircleAvatar(child: Text("${_user!.id}")),
            title: Text(_user!.name),
            subtitle: Text("Rol: ${_user!.role}"),
            tileColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        if (_user == null && !_loading) const Text("Presiona el botón para ejecutar el flujo Clean Architecture"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loadUser,
          child: const Text("Ejecutar UseCase: GetUser(101)"),
        )
      ],
    );
  }
}