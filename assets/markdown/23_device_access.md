# Device Access en Flutter: Cámara, Sensores, Ubicación

## Introducción a Device Access

Muchas apps necesitan acceder a recursos del dispositivo:
- 📷 Cámara
- 📍 GPS/Ubicación
- 📱 Sensores (acelerómetro, giroscopio)
- 🔋 Información del dispositivo
- 📞 Contactos, calendario
- 🎤 Micrófono

### Consideraciones Importantes

- ✅ Solicitar permisos
- ✅ Manejar denegaciones
- ✅ Explicar por qué se necesita
- ✅ Respetar privacidad del usuario

---

## 1. Permisos

### 1.1 Setup Inicial

```yaml
# pubspec.yaml
dependencies:
  permission_handler: ^11.4.0
  image_picker: ^1.0.0
  location: ^5.0.0
  sensors: ^2.1.0
  device_info_plus: ^9.0.0
```

### 1.2 Configurar Permisos en Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <!-- Cámara -->
  <uses-permission android:name="android.permission.CAMERA" />
  
  <!-- Ubicación -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  
  <!-- Micrófono -->
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  
  <!-- Almacenamiento -->
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  
  <application>
    <!-- ... -->
  </application>
</manifest>
```

### 1.3 Configurar Permisos en iOS

```
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    # ...
  end
end
```

```xml
<!-- ios/Runner/Info.plist -->
<dict>
  <key>NSCameraUsageDescription</key>
  <string>Necesitamos acceso a la cámara para tomar fotos</string>
  
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Necesitamos acceso a tu ubicación</string>
  
  <key>NSMicrophoneUsageDescription</key>
  <string>Necesitamos acceso al micrófono</string>
  
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Necesitamos acceso a tu galería</string>
</dict>
```

### 1.4 Clase para Manejar Permisos

```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  static Future<void> showAppSettings() async {
    await openAppSettings();
  }
}
```

---

## 2. Cámara

### 2.1 Capturar Foto

```yaml
dependencies:
  image_picker: ^1.0.0
```

```dart
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // Tomar foto con cámara
  Future<XFile?> takePicture() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return photo;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  // Seleccionar de galería
  Future<XFile?> pickFromGallery() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      return photo;
    } catch (e) {
      print('Error al seleccionar foto: $e');
      return null;
    }
  }

  // Grabar video
  Future<XFile?> recordVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
      );
      return video;
    } catch (e) {
      print('Error al grabar video: $e');
      return null;
    }
  }
}

// Widget
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _image;
  final CameraService _cameraService = CameraService();

  void _pickImage() async {
    final hasPermission = await PermissionService.requestCameraPermission();
    
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
      );
      return;
    }

    final image = await _cameraService.takePicture();
    
    if (image != null) {
      setState(() => _image = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(
                File(_image!.path),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              const Text('No hay foto'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Tomar Foto'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.2 Camera Plugin Avanzado

```yaml
dependencies:
  camera: ^0.10.0
```

```dart
import 'package:camera/camera.dart';

class AdvancedCameraScreen extends StatefulWidget {
  const AdvancedCameraScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedCameraScreen> createState() => _AdvancedCameraScreenState();
}

class _AdvancedCameraScreenState extends State<AdvancedCameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );

    await _cameraController.initialize();
    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      final image = await _cameraController.takePicture();
      print('Foto guardada en: ${image.path}');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cámara Avanzada')),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _takePicture,
                child: const Icon(Icons.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 3. Ubicación (GPS)

### 3.1 Ubicación Simple

```yaml
dependencies:
  location: ^5.0.0
```

```dart
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  // Obtener ubicación actual
  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await _requestLocationPermission();
      
      if (!hasPermission) return null;

      final currentLocation = await _location.getLocation();
      return currentLocation;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Escuchar cambios de ubicación
  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged.listen((LocationData currentLocation) {
      print('Latitud: ${currentLocation.latitude}');
      print('Longitud: ${currentLocation.longitude}');
    }).asBroadcastStream();
  }

  Future<bool> _requestLocationPermission() async {
    final permissionGranted = await _location.requestPermission();
    return permissionGranted == PermissionStatus.granted;
  }

  Future<bool> isServiceEnabled() async {
    return await _location.serviceEnabled();
  }
}

// Widget
class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  LocationData? _locationData;
  late StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningLocation();
  }

  void _startListeningLocation() {
    _locationSubscription = _locationService.getLocationStream().listen(
      (location) {
        setState(() => _locationData = location);
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación')),
      body: Center(
        child: _locationData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Latitud: ${_locationData!.latitude}'),
                  Text('Longitud: ${_locationData!.longitude}'),
                  Text('Altitud: ${_locationData!.altitude}'),
                  Text('Velocidad: ${_locationData!.speed} m/s'),
                  Text('Precisión: ${_locationData!.accuracy} m'),
                ],
              ),
      ),
    );
  }
}
```

### 3.2 Geolocalización Inversa

```yaml
dependencies:
  geocoding: ^2.1.0
```

```dart
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  // Obtener dirección desde coordenadas
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // Obtener coordenadas desde dirección
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
```

---

## 4. Sensores

### 4.1 Acelerómetro, Giroscopio

```yaml
dependencies:
  sensors_plus: ^5.0.0
```

```dart
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  Stream<AccelerometerEvent> getAccelerometerEvents() {
    return accelerometerEvents;
  }

  Stream<GyroscopeEvent> getGyroscopeEvents() {
    return gyroscopeEvents;
  }

  Stream<MagnetometerEvent> getMagnetometerEvents() {
    return magnetometerEvents;
  }
}

// Widget
class SensorDisplay extends StatefulWidget {
  const SensorDisplay({Key? key}) : super(key: key);

  @override
  State<SensorDisplay> createState() => _SensorDisplayState();
}

class _SensorDisplayState extends State<SensorDisplay> {
  final SensorService _sensorService = SensorService();
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;

  @override
  void initState() {
    super.initState();
    
    _sensorService.getAccelerometerEvents().listen((event) {
      setState(() => _accelerometerEvent = event);
    });

    _sensorService.getGyroscopeEvents().listen((event) {
      setState(() => _gyroscopeEvent = event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensores')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_accelerometerEvent != null)
              Column(
                children: [
                  const Text('Acelerómetro:'),
                  Text('X: ${_accelerometerEvent!.x.toStringAsFixed(2)}'),
                  Text('Y: ${_accelerometerEvent!.y.toStringAsFixed(2)}'),
                  Text('Z: ${_accelerometerEvent!.z.toStringAsFixed(2)}'),
                ],
              ),
            const SizedBox(height: 24),
            if (_gyroscopeEvent != null)
              Column(
                children: [
                  const Text('Giroscopio:'),
                  Text('X: ${_gyroscopeEvent!.x.toStringAsFixed(2)}'),
                  Text('Y: ${_gyroscopeEvent!.y.toStringAsFixed(2)}'),
                  Text('Z: ${_gyroscopeEvent!.z.toStringAsFixed(2)}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Información del Dispositivo

### 5.1 Device Info

```yaml
dependencies:
  device_info_plus: ^9.0.0
```

```dart
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return _getIOSDeviceInfo();
      }
    } catch (e) {
      print('Error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    final AndroidDeviceInfo androidInfo =
        await _deviceInfoPlugin.androidInfo;

    return {
      'device': androidInfo.device,
      'model': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
      'version': androidInfo.version.release,
      'sdkInt': androidInfo.version.sdkInt,
    };
  }

  Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;

    return {
      'device': iosInfo.name,
      'model': iosInfo.model,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
    };
  }
}

// Widget
class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({Key? key}) : super(key: key);

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  Map<String, dynamic> _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await _deviceInfoService.getDeviceInfo();
    setState(() => _deviceInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información del Dispositivo')),
      body: ListView(
        children: _deviceInfo.entries
            .map((e) => ListTile(
              title: Text(e.key),
              subtitle: Text(e.value.toString()),
            ))
            .toList(),
      ),
    );
  }
}
```

---

## 6. Vibración y Audio

### 6.1 Vibración

```yaml
dependencies:
  vibration: ^1.8.0
```

```dart
import 'package:vibration/vibration.dart';

class VibrationService {
  Future<void> vibrate({
    int duration = 100,
  }) async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: duration);
    }
  }

  Future<void> vibrateWithPattern({
    required List<int> pattern,
    int repeat = -1,
  }) async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: pattern, repeat: repeat);
    }
  }

  Future<void> cancel() async {
    await Vibration.cancel();
  }
}

// Uso
ElevatedButton(
  onPressed: () {
    VibrationService().vibrate();
  },
  child: const Text('Vibrar'),
)
```

---

## 7. Best Practices

✅ **DO's:**
- Solicitar permisos en tiempo de ejecución
- Explicar por qué se necesita cada permiso
- Manejar denegación de permisos
- Verificar disponibilidad de servicios
- Liberar recursos
- Testar en dispositivos reales

❌ **DON'Ts:**
- Solicitar permisos innecesarios
- No manejar errores
- Olvidar configurar manifiestos
- Usar ubicación continuamente sin necesidad
- No avisar al usuario

---

## 8. Ejercicios

### Ejercicio 1: App de Ubicación
Mostrar ubicación actual y guardarla

### Ejercicio 2: Cámara Personalizada
Crear app con filtros de cámara

### Ejercicio 3: Sensor Shake
Detectar movimiento y reaccionar

---

Conceptos Relacionados:
- 12_GESTION_ESTADO
- 15_FIREBASE
- 17_MANEJO_ERRORES
- 25_WEB_DESKTOP
- EJERCICIOS_23_DEVICE_ACCESS

## Resumen

Device access es esencial para:
- ✅ Cámara y galería
- ✅ Ubicación GPS
- ✅ Sensores del dispositivo
- ✅ Información del dispositivo
- ✅ Experiencia interactiva
