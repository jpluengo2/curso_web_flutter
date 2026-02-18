# Firebase en Flutter: Guía Completa

## Introducción a Firebase

Firebase es una plataforma de desarrollo de Google que proporciona herramientas backend sin necesidad de administrar servidores. Ofrece:

- **Autenticación**: Múltiples métodos de login
- **Firestore**: Base de datos en tiempo real
- **Storage**: Almacenamiento de archivos
- **Cloud Messaging**: Notificaciones push
- **Analytics**: Análisis de uso
- **Cloud Functions**: Funciones serverless
- **Hosting**: Hospedaje web

### Ventajas de Firebase

- ✅ Sin servidor (serverless)
- ✅ Escalabilidad automática
- ✅ Integración con Flutter
- ✅ Tiempo real
- ✅ Seguridad integrada
- ✅ Modelos de precios flexibles

---

## 1. Setup Inicial

### 1.1 Crear Proyecto Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Crear nuevo proyecto
3. Habilitar Google Analytics (opcional)
4. Esperar a que se cree el proyecto

### 1.2 Instalar CLI de Firebase

```bash
# Instalar Node.js (si no lo tienes)
# Luego:
npm install -g firebase-tools

# Login con Google
firebase login

# Verificar instalación
firebase --version
```

### 1.3 Configurar Flutter

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar proyecto
flutterfire configure

# Seleccionar plataformas: iOS, Android, Web, Windows, etc.
# Se generarán archivos de configuración automáticamente
```

### 1.4 Agregar Dependencias

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  google_sign_in: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  firebase_core_platform_interface: ^5.0.0
```

```bash
flutter pub get
```

### 1.5 Inicializar Firebase en main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  const myApp = MyApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget { const MyApp({super.key}); @override Widget build(BuildContext context) => const MaterialApp(home: Scaffold()); }
```

---

## 2. Autenticación con Firebase

### 2.1 Autenticación con Email y Contraseña

```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de usuario autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Verificar si está autenticado
  bool get isAuthenticated => currentUser != null;

  // Registrar con email y contraseña
  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar nombre de usuario
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'La contraseña es muy débil';
      } else if (e.code == 'email-already-in-use') {
        throw 'El email ya está registrado';
      }
      rethrow;
    }
  }

  // Login con email y contraseña
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        throw 'Contraseña incorrecta';
      }
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Error al enviar correo de reset';
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      throw 'Error al eliminar cuenta';
    }
  }

  // Actualizar email
  Future<void> updateEmail(String newEmail) async {
    try {
      await currentUser?.updateEmail(newEmail);
    } catch (e) {
      throw 'Error al actualizar email';
    }
  }

  // Actualizar contraseña
  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw 'Error al actualizar contraseña';
    }
  }

  // Verificar email
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Error al enviar verificación';
    }
  }
}

// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:mi_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.2 Autenticación con Google

```dart
// lib/services/google_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Autenticación cancelada';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw 'Error al autenticarse con Google: $e';
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}

// En login_screen.dart
ElevatedButton.icon(
  onPressed: () async {
    try {
      await GoogleAuthService().signInWithGoogle();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  },
  icon: const Icon(Icons.g_translate),
  label: const Text('Ingresar con Google'),
)
```

---

## 3. Firestore - Base de Datos

### 3.1 Operaciones CRUD

```dart
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
  });

  // Convertir a JSON para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }

  // Crear desde documento Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE - Agregar documento
  Future<void> addUser(User user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Error al agregar usuario: $e';
    }
  }

  // READ - Obtener documento único
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error al obtener usuario: $e';
    }
  }

  // READ - Obtener todos los documentos
  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await _db.collection('users').get();
      return querySnapshot.docs
          .map((doc) => User.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error al obtener usuarios: $e';
    }
  }

  // READ - Stream en tiempo real
  Stream<List<User>> getUsersStream() {
    return _db
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // UPDATE - Actualizar documento
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(userId).update(data);
    } catch (e) {
      throw 'Error al actualizar usuario: $e';
    }
  }

  // DELETE - Eliminar documento
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      throw 'Error al eliminar usuario: $e';
    }
  }

  // BATCH - Múltiples operaciones
  Future<void> batchUpdateUsers(Map<String, Map<String, dynamic>> updates) async {
    try {
      final batch = _db.batch();

      updates.forEach((userId, data) {
        batch.update(_db.collection('users').doc(userId), data);
      });

      await batch.commit();
    } catch (e) {
      throw 'Error en batch update: $e';
    }
  }

  // TRANSACTION - Operación atómica
  Future<void> transferCredit(
    String fromUserId,
    String toUserId,
    double amount,
  ) async {
    try {
      await _db.runTransaction((transaction) async {
        final fromDoc =
            await transaction.get(_db.collection('users').doc(fromUserId));
        final toDoc =
            await transaction.get(_db.collection('users').doc(toUserId));

        final fromBalance = (fromDoc['balance'] ?? 0) as double;
        final toBalance = (toDoc['balance'] ?? 0) as double;

        if (fromBalance < amount) {
          throw 'Saldo insuficiente';
        }

        transaction.update(
          _db.collection('users').doc(fromUserId),
          {'balance': fromBalance - amount},
        );

        transaction.update(
          _db.collection('users').doc(toUserId),
          {'balance': toBalance + amount},
        );
      });
    } catch (e) {
      throw 'Error en transferencia: $e';
    }
  }
}
```

### 3.2 Consultas Avanzadas

```dart
// Queries en Firestore
class FirestoreQueries {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Filtrar por campo
  Stream<List<User>> getUsersByCity(String city) {
    return _db
        .collection('users')
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // Múltiples filtros
  Stream<List<User>> getActiveUsersInCity(String city) {
    return _db
        .collection('users')
        .where('city', isEqualTo: city)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // Ordenar resultados
  Stream<List<User>> getUsersSortedByAge(String city) {
    return _db
        .collection('users')
        .where('city', isEqualTo: city)
        .orderBy('age', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // Limitar resultados
  Stream<List<User>> getTopUsers(int limit) {
    return _db
        .collection('users')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // Paginación
  Stream<List<User>> getPaginatedUsers(int pageSize) {
    return _db
        .collection('users')
        .orderBy('name')
        .limit(pageSize)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  // Búsqueda por rango
  Future<List<User>> getUsersByAgeRange(int minAge, int maxAge) async {
    final query = await _db
        .collection('users')
        .where('age', isGreaterThanOrEqualTo: minAge)
        .where('age', isLessThanOrEqualTo: maxAge)
        .get();

    return query.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  // Búsqueda de texto (simple)
  Future<List<User>> searchUsersByName(String query) async {
    final snapshot = await _db.collection('users').get();
    final results = snapshot.docs
        .map((doc) => User.fromFirestore(doc))
        .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results;
  }

  // Array contains
  Future<List<User>> getUsersWithTag(String tag) async {
    final query = await _db
        .collection('users')
        .where('tags', arrayContains: tag)
        .get();

    return query.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  // Aggregate Query (contar documentos)
  Future<int> countUsers() async {
    final snapshot = await _db
        .collection('users')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
```

### 3.3 Widget con Firestore

```dart
// lib/screens/users_list_screen.dart
class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: StreamBuilder<List<User>>(
        stream: firestoreService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await firestoreService.deleteUser(user.id);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(userId: user.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 4. Firebase Storage

### 4.1 Subir y Descargar Archivos

```dart
// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir archivo
  Future<String> uploadFile({
    required File file,
    required String path,
    required Function(double) onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      final uploadTask = ref.putFile(file);

      // Escuchar progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final percent = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(percent);
      });

      await uploadTask;

      // Obtener URL de descarga
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Error al subir archivo: $e';
    }
  }

  // Subir imagen de galería
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    required Function(double) onProgress,
  }) async {
    final fileName = 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadFile(
      file: imageFile,
      path: fileName,
      onProgress: onProgress,
    );
  }

  // Descargar archivo
  Future<File> downloadFile({
    required String path,
    required String localPath,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final file = File(localPath);

      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw 'Error al descargar archivo: $e';
    }
  }

  // Eliminar archivo
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      throw 'Error al eliminar archivo: $e';
    }
  }

  // Listar archivos
  Future<List<String>> listFiles(String path) async {
    try {
      final result = await _storage.ref().child(path).listAll();
      return result.items.map((ref) => ref.name).toList();
    } catch (e) {
      throw 'Error al listar archivos: $e';
    }
  }

  // Obtener URL de descarga
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      throw 'Error al obtener URL: $e';
    }
  }
}

// Widget para subir imagen
class ImageUploadWidget extends StatefulWidget {
  final Function(String) onImageUploaded;

  const ImageUploadWidget({
    Key? key,
    required this.onImageUploaded,
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  double _uploadProgress = 0;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isUploading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CircularProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUploadImage,
          icon: const Icon(Icons.image),
          label: const Text('Subir Imagen'),
        ),
      ],
    );
  }

  void _pickAndUploadImage() async {
    // Aquí iría la lógica para seleccionar imagen
    // (requiere image_picker package)
    try {
      // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // if (image != null) {
      //   setState(() => _isUploading = true);
      //   final url = await StorageService().uploadImage(
      //     imageFile: File(image.path),
      //     userId: FirebaseAuth.instance.currentUser!.uid,
      //     onProgress: (progress) {
      //       setState(() => _uploadProgress = progress);
      //     },
      //   );
      //   widget.onImageUploaded(url);
      //   setState(() => _isUploading = false);
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

---

## 5. Notificaciones Push con Cloud Messaging

### 5.1 Setup

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^14.7.0
```

### 5.2 Manejo de Notificaciones

```dart
// lib/services/messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initializeMessaging() async {
    // Solicitar permiso al usuario
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos otorgados');
    }

    // Obtener token del dispositivo
    final token = await _messaging.getToken();
    print('Device Token: $token');

    // Escuchar mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido: ${message.notification?.title}');
      // Mostrar notificación personalizada
    });

    // Escuchar cuando se toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta: ${message.notification?.title}');
      // Navegar a pantalla específica
    });

    // Escuchar mensajes en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Obtener token del dispositivo
  Future<String?> getDeviceToken() async {
    return await _messaging.getToken();
  }

  // Suscribirse a tema
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Suscrito a: $topic');
  }

  // Desuscribirse de tema
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Desuscrito de: $topic');
  }
}

// Handler global para mensajes en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje background: ${message.notification?.title}');
}

// En main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MessagingService().initializeMessaging();
  runApp(const MyApp());
}
```

### 5.3 Recibir Notificaciones Personalizadas

```dart
// lib/widgets/notification_listener.dart
class NotificationListener extends StatefulWidget {
  final Widget child;

  const NotificationListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message.notification?.title ?? 'Notificación'),
          content: Text(message.notification?.body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

---

## 6. Security Rules

### 6.1 Firestore Rules

```javascript
// Firestore Rules (en Firebase Console)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Acceso público a lectura, solo propietario puede escribir
    match /users/{userId} {
      allow read: if true;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId;
    }

    // Solo usuarios autenticados pueden leer y escribir
    match /posts/{postId} {
      allow read, write: if request.auth != null;
    }

    // Validar datos al escribir
    match /users/{userId} {
      allow write: if request.resource.data.email is string &&
                      request.resource.data.email.size() > 0;
    }

    // Control de rol
    match /admin/{document=**} {
      allow read, write: if request.auth.token.admin == true;
    }
  }
}
```

### 6.2 Storage Rules

```javascript
// Storage Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Solo propietario puede acceder a sus archivos
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }

    // Público para lectura, solo propietario para escritura
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 7. Patrones Avanzados

### 7.1 Patrón Repository

```dart
// lib/repositories/user_repository.dart
abstract class IUserRepository {
  Future<User?> getUser(String userId);
  Stream<List<User>> getAllUsers();
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
}

class FirebaseUserRepository implements IUserRepository {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Future<User?> getUser(String userId) async {
    return await _firestoreService.getUser(userId);
  }

  @override
  Stream<List<User>> getAllUsers() {
    return _firestoreService.getUsersStream();
  }

  @override
  Future<void> createUser(User user) async {
    await _firestoreService.addUser(user);
  }

  @override
  Future<void> updateUser(User user) async {
    await _firestoreService.updateUser(user.id, user.toMap());
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestoreService.deleteUser(userId);
  }
}
```

### 7.2 Patrón ViewModel

```dart
// lib/view_models/users_view_model.dart
class UsersViewModel extends ChangeNotifier {
  final IUserRepository _userRepository;

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UsersViewModel(this._userRepository);

  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userRepository.getAllUsers().listen((users) {
        _users = users;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### 7.3 Usar ViewModel

```dart
// lib/screens/users_screen.dart
class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersViewModel(FirebaseUserRepository())..loadUsers(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Usuarios')),
        body: Consumer<UsersViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(child: Text('Error: ${viewModel.error}'));
            }

            return ListView.builder(
              itemCount: viewModel.users.length,
              itemBuilder: (context, index) {
                final user = viewModel.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => viewModel.deleteUser(user.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
```

---

## 8. Mejores Prácticas

✅ **Usar TypeSafety**: Crear modelos para cada colección
✅ **Validar datos**: En el cliente y en las reglas
✅ **Cachear datos**: Para mejorar performance
✅ **Usar streams**: En lugar de futures cuando sea posible
✅ **Manejo de errores**: Capturar excepciones específicas
✅ **Seguridad**: Implementar Security Rules robustas
✅ **Índices**: Crear índices para queries complejas
✅ **Monitoreo**: Usar Firebase Analytics

---

## 9. Troubleshooting Común

### Error: "PERMISSION_DENIED"
- Verificar Security Rules
- Asegurarse de estar autenticado
- Revisar estructura del documento

### Error: "User not found"
- Usar `await _auth.createUserWithEmailAndPassword` primero
- Verificar que el usuario exista en la BD

### Storage lento
- Optimizar tamaño de imágenes
- Usar URLs de descarga cached
- Considerar Cloud CDN

---

## Ejercicios

### Ejercicio 1: App de Tareas
Crear app con:
- Login/Registro
- CRUD de tareas
- Sincronización en tiempo real

### Ejercicio 2: App Social
Crear app con:
- Perfiles de usuario
- Feed de posts
- Likes y comentarios

### Ejercicio 3: E-commerce
Crear app con:
- Catálogo de productos
- Carrito de compras
- Historial de pedidos
- Notificaciones

---

## Resumen

Firebase proporciona herramientas completas para aplicaciones modernas.

Conceptos Relacionados:
- 12_GESTION_ESTADO
- 13_PERSISTENCIA_DATOS
- 14_CONSUMO_APIS
- 23_DEVICE_ACCESS
- EJERCICIOS_15_FIREBASE
