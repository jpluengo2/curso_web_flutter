# Persistencia de Datos en Flutter - Guía Completa

## 📚 Tabla de Contenidos
1. [Introducción](#introducción)
2. [SharedPreferences](#sharedpreferences)
3. [SQLite con sqflite](#sqlite-con-sqflite)
4. [Hive](#hive)
5. [Isar](#isar)
6. [FileSystem](#filesystem)
7. [JSON](#json)
8. [Encriptación](#encriptación)
9. [Caché](#caché)
10. [Ejemplos prácticos](#ejemplos-prácticos)
11. [Mejores prácticas](#mejores-prácticas)

---

## Introducción

La persistencia de datos es guardar información de forma permanente en el dispositivo. Hay varias opciones según el caso de uso:

### ¿Cuándo usar cada una?

| Tipo | Datos | Complejidad | Cuando usar |
|------|-------|-------------|-----------|
| **SharedPreferences** | Pequeños | Muy simple | Configuración, preferencias |
| **SQLite** | Grande | Media | Datos estructurados, relaciones |
| **Hive** | Grande | Simple | NoSQL, desarrollo rápido |
| **Isar** | Grande | Simple | NoSQL moderno, rendimiento |
| **FileSystem** | Archivos | Media | Documentos, imágenes |
| **Encriptación** | Sensibles | Alta | Datos confidenciales |

---

## SharedPreferences

### ¿Qué es SharedPreferences?

Almacena pequeños datos clave-valor en el dispositivo. Ideal para:
- Preferencias de usuario
- Configuración
- Estado simple

```dart
import 'package:shared_preferences/shared_preferences.dart';

// Instalación
// dependencies:
//   shared_preferences: ^2.2.0

class PreferencesHelper {
  // Variables privadas
  static late final SharedPreferences _prefs;

  // Inicializar (en main())
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== GUARDAR =====
  static Future<bool> saveString(String key, String value) {
    return _prefs.setString(key, value);
  }

  static Future<bool> saveInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  static Future<bool> saveDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  static Future<bool> saveBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  static Future<bool> saveList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  // ===== OBTENER =====
  static String? getString(String key, [String? defaultValue]) {
    return _prefs.getString(key) ?? defaultValue;
  }

  static int? getInt(String key, [int? defaultValue]) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  static double? getDouble(String key, [double? defaultValue]) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  static bool? getBool(String key, [bool? defaultValue]) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  static List<String> getList(String key, [List<String>? defaultValue]) {
    return _prefs.getStringList(key) ?? defaultValue ?? [];
  }

  // ===== ELIMINAR =====
  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  static Future<bool> clear() {
    return _prefs.clear();
  }

  // ===== UTILIDADES =====
  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  static Set<String> getKeys() {
    return _prefs.getKeys();
  }
}

// Uso en main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesHelper.init();
  runApp(MyApp());
}

// Usar en la app
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _userName = '';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userName = PreferencesHelper.getString('userName', 'Usuario') ?? 'Usuario';
    _isDarkMode = PreferencesHelper.getBool('isDarkMode', false) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SharedPreferences')),
      body: Column(
        children: [
          Text('Usuario: $_userName'),
          SizedBox(height: 16),
          SwitchListTile(
            title: Text('Modo oscuro'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              PreferencesHelper.saveBool('isDarkMode', value);
            },
          ),
          ElevatedButton(
            onPressed: () async {
              await PreferencesHelper.saveString('userName', 'Juan');
              _loadData();
              setState(() {});
            },
            child: Text('Guardar datos'),
          ),
        ],
      ),
    );
  }
}
```

### Constantes para claves

```dart
class PreferencesKeys {
  // User
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userId = 'user_id';
  static const String userToken = 'user_token';

  // Settings
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'language';
  static const String fontSize = 'font_size';

  // App state
  static const String lastLoginTime = 'last_login_time';
  static const String isFirstLaunch = 'is_first_launch';
  static const String appVersion = 'app_version';

  // Cache
  static const String cachedUserData = 'cached_user_data';
  static const String lastSyncTime = 'last_sync_time';
}

// Uso
PreferencesHelper.saveString(PreferencesKeys.userName, 'Juan');
String? name = PreferencesHelper.getString(PreferencesKeys.userName);
```

---

## SQLite con sqflite

### Configuración básica

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Instalación
// dependencies:
//   sqflite: ^2.3.0
//   path: ^1.8.0

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creando base de datos...');
    
    // Tabla: users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Tabla: posts
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        createdAt TEXT,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Crear índices para búsquedas rápidas
    await db.execute('''
      CREATE INDEX idx_posts_userId ON posts(userId)
    ''');

    print('Base de datos creada');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Actualizando base de datos de $oldVersion a $newVersion');
    
    // Agregar nuevas columnas
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
    }
    
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE posts ADD COLUMN imageUrl TEXT');
    }
  }

  Future<void> _onOpen(Database db) async {
    print('Base de datos abierta');
  }

  // ===== CRUD USERS =====

  // CREATE (Insertar)
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      {
        ...user,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ (Obtener)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // UPDATE (Actualizar)
  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      {
        ...user,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE (Eliminar)
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== CONSULTAS AVANZADAS =====

  // Búsqueda
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // Contar registros
  Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Usuario con sus posts
  Future<Map<String, dynamic>?> getUserWithPosts(int userId) async {
    final db = await database;
    
    final user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (user.isEmpty) return null;

    final posts = await db.query(
      'posts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return {
      'user': user.first,
      'posts': posts,
    };
  }

  // Transacción
  Future<void> createUserWithPosts(
    Map<String, dynamic> user,
    List<Map<String, dynamic>> posts,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insertar usuario
      final userId = await txn.insert('users', user);

      // Insertar posts del usuario
      for (var post in posts) {
        await txn.insert('posts', {
          ...post,
          'userId': userId,
        });
      }
    });
  }

  // Batch operations
  Future<void> insertMultipleUsers(List<Map<String, dynamic>> users) async {
    final db = await database;
    final batch = db.batch();

    for (var user in users) {
      batch.insert('users', user);
    }

    await batch.commit();
  }

  // Cerrar base de datos
  Future<void> close() async {
    final db = await _database;
    await db?.close();
  }
}
```

### Modelo y Repository

```dart
class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  // Convertir a Map para base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Crear desde Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : null,
      updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : null,
    );
  }

  // Copy with
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Repository
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Crear
  Future<int> addUser(User user) async {
    return await _dbHelper.insertUser(user.toMap());
  }

  // Obtener todos
  Future<List<User>> getUsers() async {
    final maps = await _dbHelper.getAllUsers();
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Obtener por ID
  Future<User?> getUserById(int id) async {
    final map = await _dbHelper.getUserById(id);
    return map != null ? User.fromMap(map) : null;
  }

  // Actualizar
  Future<int> updateUser(User user) async {
    return await _dbHelper.updateUser(user.id!, user.toMap());
  }

  // Eliminar
  Future<int> deleteUser(int id) async {
    return await _dbHelper.deleteUser(id);
  }

  // Buscar
  Future<List<User>> searchUsers(String query) async {
    final maps = await _dbHelper.searchUsers(query);
    return maps.map((map) => User.fromMap(map)).toList();
  }
}
```

### Uso en Flutter

```dart
class UsersScreen extends StatefulWidget {
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserRepository _repository = UserRepository();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    _usersFuture = _repository.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios')),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(child: Text('No hay usuarios'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Editar'),
                      onTap: () {
                        // Editar
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Eliminar'),
                      onTap: () async {
                        await _repository.deleteUser(user.id!);
                        _refreshUsers();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newUser = User(
            name: 'Nuevo usuario',
            email: 'nuevo@example.com',
          );
          await _repository.addUser(newUser);
          _refreshUsers();
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## Hive

### Configuración y uso

```dart
import 'package:hive_flutter/hive_flutter.dart';

// Instalación
// dependencies:
//   hive_flutter: ^1.1.0
// dev_dependencies:
//   hive_generator: ^2.0.0
//   build_runner: ^2.4.0

// Inicialización en main()
void main() async {
  await Hive.initFlutter();
  
  // Registrar adaptadores
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(SettingsAdapter());
  
  Hive.registerAdapter(UserAdapter());
  
  // Abrir cajas
  await Hive.openBox<User>('users');
  await Hive.openBox<Map>('settings');
  
  runApp(MyApp());
}

// Definir modelo con anotaciones
part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
  });
}

// Generar adaptador
// flutter pub run build_runner build

// Repository
class UserRepositoryHive {
  static const String _boxName = 'users';

  // Guardar usuario
  Future<void> saveUser(User user) async {
    final box = Hive.box<User>(_boxName);
    await box.put(user.id, user);
  }

  // Obtener usuario
  Future<User?> getUser(String id) async {
    final box = Hive.box<User>(_boxName);
    return box.get(id);
  }

  // Obtener todos
  Future<List<User>> getAllUsers() async {
    final box = Hive.box<User>(_boxName);
    return box.values.toList();
  }

  // Buscar
  Future<List<User>> searchUsers(String query) async {
    final box = Hive.box<User>(_boxName);
    return box.values
      .where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
        user.email.toLowerCase().contains(query.toLowerCase()))
      .toList();
  }

  // Actualizar
  Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  // Eliminar
  Future<void> deleteUser(String id) async {
    final box = Hive.box<User>(_boxName);
    await box.delete(id);
  }

  // Escuchar cambios
  Stream<BoxEvent> watchUsers() {
    final box = Hive.box<User>(_boxName);
    return box.watch();
  }

  // Contar
  int getUserCount() {
    final box = Hive.box<User>(_boxName);
    return box.length;
  }

  // Limpiar todo
  Future<void> clear() async {
    final box = Hive.box<User>(_boxName);
    await box.clear();
  }
}

// Settings repository
@HiveType(typeId: 1)
class Settings {}
class SettingsRepositoryHive {
  static const String _boxName = 'settings';

  Future<void> setDarkMode(bool value) async {
    final box = Hive.box(_boxName);
    await box.put('darkMode', value);
  }

  bool isDarkMode() {
    final box = Hive.box(_boxName);
    return box.get('darkMode', defaultValue: false);
  }

  Future<void> setLanguage(String language) async {
    final box = Hive.box(_boxName);
    await box.put('language', language);
  }

  String getLanguage() {
    final box = Hive.box(_boxName);
    return box.get('language', defaultValue: 'es');
  }

  Stream<BoxEvent> watchSettings() {
    final box = Hive.box(_boxName);
    return box.watch();
  }
}
```

### Uso con cambios en tiempo real

```dart
class UsersHiveScreen extends StatelessWidget {
  final UserRepositoryHive _repository = UserRepositoryHive();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios (Hive)')),
      body: StreamBuilder<BoxEvent>(
        stream: _repository.watchUsers(),
        builder: (context, snapshot) {
          final users = _repository.getAllUsers();

          if (users.isEmpty) {
            return Center(child: Text('No hay usuarios'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _repository.deleteUser(user.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = User(
            id: DateTime.now().toString(),
            name: 'Usuario ${DateTime.now().millisecond}',
            email: 'user@example.com',
          );
          await _repository.saveUser(user);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## Isar

### Configuración

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Instalación
// dependencies:
//   isar: ^3.1.0
//   isar_flutter_libs: ^3.1.0
// dev_dependencies:
//   isar_generator: ^3.1.0

// Inicializar
Future<Isar> openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [UserSchema, PostSchema],
    directory: dir.path,
  );
}

// Definir modelo
part 'user.g.dart';

@collection
class User {
  Id? id = Isar.autoIncrement;
  
  late String name;
  
  @Index(unique: true)
  late String email;
  
  String? phone;
  
  late DateTime createdAt;

  final posts = IsarLinks<Post>();
}

part 'post.g.dart';

@collection
class Post {
  Id? id = Isar.autoIncrement;
  
  late String title;
  
  String? content;
  
  late DateTime createdAt;

  final user = IsarLink<User>();
}

// Generar código
// flutter pub run build_runner build

// Repository
class UserRepositoryIsar {
  final Isar isar;

  UserRepositoryIsar(this.isar);

  // Crear
  Future<Id> addUser(User user) async {
    return await isar.writeTxn(() async {
      return await isar.users.put(user);
    });
  }

  // Leer todos
  Future<List<User>> getUsers() async {
    return await isar.users.where().findAll();
  }

  // Leer por ID
  Future<User?> getUserById(Id id) async {
    return await isar.users.get(id);
  }

  // Buscar por email
  Future<User?> getUserByEmail(String email) async {
    return await isar.users.where().emailEqualTo(email).findFirst();
  }

  // Actualizar
  Future<void> updateUser(User user) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  // Eliminar
  Future<void> deleteUser(Id id) async {
    await isar.writeTxn(() async {
      await isar.users.delete(id);
    });
  }

  // Filtrar
  Future<List<User>> getUsersCreatedAfter(DateTime date) async {
    return await isar.users
      .where()
      .createdAtGreaterThan(date)
      .findAll();
  }

  // Buscar
  Future<List<User>> searchUsers(String query) async {
    return await isar.users
      .where()
      .nameContains(query, caseSensitive: false)
      .findAll();
  }

  // Watch (escuchar cambios)
  Stream<List<User>> watchUsers() {
    return isar.users.where().watch(fireImmediately: true);
  }

  // Contar
  Future<int> getUserCount() async {
    return await isar.users.count();
  }

  // Transacción: Usuario con posts
  Future<void> createUserWithPosts(User user, List<Post> posts) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
      await isar.posts.putAll(posts);
      
      // Relacionar
      for (var post in posts) {
        post.user.value = user;
      }
    });
  }

  // Obtener usuario con posts
  Future<User?> getUserWithPosts(Id userId) async {
    final user = await isar.users.get(userId);
    if (user != null) {
      await user.posts.load();
    }
    return user;
  }

  // Estadísticas
  Future<void> getStats() async {
    final count = await isar.users.count();
    final oldest = await isar.users.where().findFirst();
    print('Total usuarios: $count');
    print('Más antiguo: ${oldest?.createdAt}');
  }

  // Limpiar
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.users.clear();
      await isar.posts.clear();
    });
  }
}

// Inicializar en main
void main() async {
  final isar = await openDatabase();
  runApp(MyApp(isar: isar));
}
```

---

## FileSystem

### Leer y escribir archivos

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Instalación
// dependencies:
//   path_provider: ^2.1.0

class FileHelper {
  // Obtener directorio de documentos
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Obtener directorio de caché
  static Future<Directory> getCacheDirectory() async {
    return await getApplicationCacheDirectory();
  }

  // Obtener directorio temporal
  static Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  // Guardar texto
  static Future<File> saveTextFile(String filename, String content) async {
    final dir = await getDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.writeAsString(content);
  }

  // Leer texto
  static Future<String> readTextFile(String filename) async {
    try {
      final dir = await getDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      return await file.readAsString();
    } catch (e) {
      print('Error leyendo archivo: $e');
      return '';
    }
  }

  // Guardar JSON
  static Future<File> saveJsonFile(String filename, Map<String, dynamic> data) async {
    final dir = await getDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.writeAsString(jsonEncode(data));
  }

  // Leer JSON
  static Future<Map<String, dynamic>?> readJsonFile(String filename) async {
    try {
      final content = await readTextFile(filename);
      if (content.isEmpty) return null;
      return jsonDecode(content);
    } catch (e) {
      print('Error leyendo JSON: $e');
      return null;
    }
  }

  // Guardar bytes (imagen, etc)
  static Future<File> saveBytesFile(String filename, List<int> bytes) async {
    final dir = await getDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.writeAsBytes(bytes);
  }

  // Leer bytes
  static Future<List<int>?> readBytesFile(String filename) async {
    try {
      final dir = await getDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      return await file.readAsBytes();
    } catch (e) {
      print('Error leyendo bytes: $e');
      return null;
    }
  }

  // Listar archivos
  static Future<List<FileSystemEntity>> listFiles() async {
    final dir = await getDocumentsDirectory();
    return dir.listSync();
  }

  // Eliminar archivo
  static Future<void> deleteFile(String filename) async {
    final dir = await getDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Comprobar si existe
  static Future<bool> fileExists(String filename) async {
    final dir = await getDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists();
  }

  // Tamaño del archivo
  static Future<int> getFileSize(String filename) async {
    final dir = await getDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Limpiar directorio
  static Future<void> clearDirectory() async {
    final dir = await getDocumentsDirectory();
    final files = dir.listSync();
    for (var file in files) {
      if (file is File) {
        await file.delete();
      }
    }
  }
}

// Uso
class FileStorageExample extends StatefulWidget {
  @override
  State<FileStorageExample> createState() => _FileStorageExampleState();
}

class _FileStorageExampleState extends State<FileStorageExample> {
  String _fileContent = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Storage')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await FileHelper.saveTextFile(
                  'datos.txt',
                  'Contenido guardado ${DateTime.now()}',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Archivo guardado')),
                );
              },
              child: Text('Guardar'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final content = await FileHelper.readTextFile('datos.txt');
                setState(() => _fileContent = content);
              },
              child: Text('Leer'),
            ),
            SizedBox(height: 16),
            Text('Contenido: $_fileContent'),
          ],
        ),
      ),
    );
  }
}
```

---

## JSON

### Serialización y deserialización

```dart
import 'dart:convert';

class JsonHelper {
  // Guardar objeto a JSON
  static String encodeToJson<T>(T object) {
    if (object is Map || object is List) {
      return jsonEncode(object);
    }
    return jsonEncode(object);
  }

  // Cargar objeto de JSON
  static T decodeFromJson<T>(String json, T Function(Map<String, dynamic>) fromJson) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return fromJson(map);
  }

  // Cargar lista de JSON
  static List<T> decodeListFromJson<T>(
    String json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = jsonDecode(json) as List;
    return list
      .map((item) => fromJson(item as Map<String, dynamic>))
      .toList();
  }
}

// Modelo
class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Uso
final user = User(
  id: 1,
  name: 'Juan',
  email: 'juan@example.com',
  createdAt: DateTime.now(),
);

// Convertir a JSON
final jsonString = jsonEncode(user.toJson());
print(jsonString);

// Convertir de JSON
final userFromJson = User.fromJson(jsonDecode(jsonString));
print(userFromJson.name);

// Guardar lista de usuarios
final users = [user, user];
final jsonList = jsonEncode(users.map((u) => u.toJson()).toList());

// Cargar lista
final usersList = (jsonDecode(jsonList) as List)
  .map((item) => User.fromJson(item))
  .toList();
```

### Con json_serializable

part 'user.g.dart';

```dart
import 'package:json_annotation/json_annotation.dart';

// Instalación
// dependencies:
//   json_annotation: ^4.8.0
// dev_dependencies:
//   json_serializable: ^6.7.0
//   build_runner: ^2.4.0

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
    _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// Generar código
// flutter pub run build_runner build

// Uso
final json = {'id': 1, 'name': 'Juan', 'email': 'juan@example.com', 'created_at': '2026-02-05T10:00:00'};
final user = User.fromJson(json);
final jsonOutput = user.toJson();
```

---

## Encriptación

### Almacenamiento seguro

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

// Instalación
// dependencies:
//   flutter_secure_storage: ^9.0.0
//   encrypt: ^4.0.0

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyAlias: 'key',
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_this_device_this_app_only,
    ),
  );

  // Guardar texto (encriptado automáticamente)
  static Future<void> saveSecureString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Leer texto
  static Future<String?> readSecureString(String key) async {
    return await _storage.read(key: key);
  }

  // Guardar token
  static Future<void> saveToken(String token) async {
    await saveSecureString('auth_token', token);
  }

  // Leer token
  static Future<String?> getToken() async {
    return await readSecureString('auth_token');
  }

  // Guardar credenciales
  static Future<void> saveCredentials(String username, String password) async {
    await saveSecureString('username', username);
    await saveSecureString('password', password);
  }

  // Leer credenciales
  static Future<Map<String, String?>> getCredentials() async {
    return {
      'username': await readSecureString('username'),
      'password': await readSecureString('password'),
    };
  }

  // Eliminar
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Limpiar todo
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

// Encriptación manual
class EncryptionHelper {
  static late final encrypt.Key _key;
  static late final encrypt.IV _iv;

  static void initialize() {
    _key = encrypt.Key.fromLength(32);
    _iv = encrypt.IV.fromLength(16);
  }

  static String encryptText(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}

// Uso
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Seguro')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Guardar credenciales de forma segura
                await SecureStorageHelper.saveCredentials(
                  _usernameController.text,
                  _passwordController.text,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Credenciales guardadas de forma segura')),
                );
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Caché

### Implementar caché

```dart
class CacheHelper {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration _defaultDuration = Duration(minutes: 5);

  static void set(
    String key,
    dynamic value, [
    Duration duration = _defaultDuration,
  ]) {
    _cache[key] = CacheEntry(
      value,
      DateTime.now().add(duration),
    );
  }

  static dynamic get(String key) {
    final entry = _cache[key];
    
    if (entry == null) return null;
    
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  static bool hasKey(String key) {
    return get(key) != null;
  }

  static void remove(String key) {
    _cache.remove(key);
  }

  static void clear() {
    _cache.clear();
  }

  static int getCacheSize() {
    return _cache.length;
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// Uso
class CacheExampleScreen extends StatefulWidget {
  @override
  State<CacheExampleScreen> createState() => _CacheExampleScreenState();
}

class _CacheExampleScreenState extends State<CacheExampleScreen> {
  String _cachedData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Caché')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                final data = 'Datos importantes ${DateTime.now()}';
                CacheHelper.set('myData', data, Duration(minutes: 10));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Datos en caché')),
                );
              },
              child: Text('Guardar en caché'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final data = CacheHelper.get('myData');
                setState(() => _cachedData = data ?? 'No hay datos');
              },
              child: Text('Leer de caché'),
            ),
            SizedBox(height: 16),
            Text('Datos: $_cachedData'),
          ],
        ),
      ),
    );
  }
}
```

---

## Ejemplos Prácticos

### Aplicación de notas con persistencia

```dart
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class NotesRepository {
  static const String _filename = 'notes.json';

  Future<void> addNote(Note note) async {
    final notes = await getNotes();
    notes.add(note);
    await _saveNotes(notes);
  }

  Future<List<Note>> getNotes() async {
    final content = await FileHelper.readTextFile(_filename);
    if (content.isEmpty) return [];
    
    final list = jsonDecode(content) as List;
    return list
      .map((item) => Note.fromJson(item as Map<String, dynamic>))
      .toList();    
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveNotes(notes);
  }

  Future<void> updateNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
      await _saveNotes(notes);
    }
  }

  Future<void> _saveNotes(List<Note> notes) async {
    final jsonList = notes.map((note) => note.toJson()).toList();
    await FileHelper.saveTextFile(_filename, jsonEncode(jsonList));
  }
}

class NotesApp extends StatefulWidget {
  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final NotesRepository _repository = NotesRepository();
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    _notesFuture = _repository.getNotes();
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(title: Text('Mis Notas')),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(child: Text('No hay notas'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _repository.deleteNote(note.id);
                    _loadNotes();
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final note = Note(
            id: DateTime.now().toString(),
            title: 'Nueva nota',
            content: 'Contenido',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _repository.addNote(note);
          _loadNotes();
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## Mejores Prácticas

### 1. Elegir el almacenamiento correcto

```dart
// ✅ SharedPreferences: Configuración simple
PreferencesHelper.saveBool('isDarkMode', true);

// ✅ SQLite: Datos estructurados
await databaseHelper.insertUser(userData);

// ✅ Hive: NoSQL simple y rápido
await userRepository.saveUser(user);

// ✅ FileSystem: Archivos grandes
await FileHelper.saveBytesFile('image.jpg', bytes);
```

### 2. Patrones de Repository

```dart
// ✅ Bien
class UserRepository {
  final DatabaseHelper _db;
  
  UserRepository(this._db);
  
  Future<User> getUser(int id) async {
    return await _db.getUserById(id);
  }
}

// ❌ Evitar
class UserScreen extends State {
  void initState() {
    // No acceder directamente a la BD desde widgets
    // DatabaseHelper().getUserById(1);
  }
}
```

### 3. Manejo de errores

```dart
// ✅ Bien
Future<List<User>> getUsers() async {
  try {
    return await _db.getAllUsers();
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

// ❌ Evitar
Future<List<User>> getUsers() async {
  return await _db.getAllUsers(); // Sin manejo de errores
}
```

### 4. Siempre limpiar recursos

```dart
// ✅ Bien
@override
void dispose() {
  _controller.dispose();
  DatabaseHelper().close();
  super.dispose();
}

// ❌ Evitar
@override
void dispose() {
  super.dispose(); // Sin limpiar recursos
}
```

### 5. Usar transacciones para operaciones críticas

```dart
// ✅ Bien
await isar.writeTxn(() async {
  await isar.users.put(user);
  await isar.posts.putAll(posts);
});

// ❌ Evitar
await isar.users.put(user);
await isar.posts.putAll(posts); // Sin transacción
```

### 6. Encriptar datos sensibles

```dart
// ✅ Bien
await SecureStorageHelper.saveToken(token);

// ❌ Evitar
await PreferencesHelper.saveString('token', token); // Sin encriptar
```

### 7. Usar lazy initialization

```dart
// ✅ Bien
final DatabaseHelper _db = DatabaseHelper._instance;

// ❌ Evitar
final DatabaseHelper _db = DatabaseHelper();
// Se crea múltiples instancias
```

### 8. Cache para mejora de rendimiento

```dart
// ✅ Bien
Future<User> getUser(int id) async {
  if (CacheHelper.hasKey('user_$id')) {
    return CacheHelper.get('user_$id');
  }
  
  final user = await _db.getUserById(id);
  CacheHelper.set('user_$id', user);
  return user;
}
```

### 9. Indices en bases de datos

```dart
// ✅ Bien: Crear índices para búsquedas frecuentes
await db.execute('''
  CREATE INDEX idx_users_email ON users(email)
''');

// ❌ Evitar: Búsquedas sin índices en tablas grandes
```

### 10. Migración de versiones

```dart
// ✅ Bien: Versionar la base de datos
Future<Database> _initDatabase() async {
  return await openDatabase(
    path,
    version: 3,
    onUpgrade: _onUpgrade,
  );
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
  }
  if (oldVersion < 3) {
    await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
  }
}
```

---

## Checklist de Persistencia

- ✅ Definir tipo de almacenamiento según caso de uso
- ✅ Usar Repository pattern
- ✅ Manejar errores apropiadamente
- ✅ Limpiar recursos en dispose()
- ✅ Encriptar datos sensibles
- ✅ Usar transacciones para operaciones críticas
- ✅ Crear índices en bases de datos
- ✅ Implementar migraciones de versiones
- ✅ Usar caché para mejorar rendimiento
- ✅ Testear persistencia

---

Conceptos Relacionados:
- 07_FORMULARIOS
- 12_GESTION_ESTADO
- 14_CONSUMO_APIS
- 15_FIREBASE
- EJERCICIOS_13_PERSISTENCIA

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio/Avanzado**
