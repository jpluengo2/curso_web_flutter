import 'package:flutter/material.dart';

class Lab26Branding extends StatelessWidget {
  const Lab26Branding({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 26: Branding e Identidad", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. APP ICON PREVIEW ---
        _buildSectionHeader("1. Icono de Aplicación (Launcher Icon)"),
        const Text("Simulación de cómo se ve tu icono en Android e iOS."),
        const SizedBox(height: 10),
        _buildExampleCard("Previsualizador de Icono", const IconPreviewer()),
        const SizedBox(height: 30),

        // --- 2. SPLASH SCREEN ---
        _buildSectionHeader("2. Native Splash Screen"),
        const Text("La primera pantalla que ve el usuario mientras carga Flutter."),
        const SizedBox(height: 10),
        _buildExampleCard("Simulador de Splash", const SplashSimulator()),
        const SizedBox(height: 30),

        // --- 3. FLAVORS ---
        _buildSectionHeader("3. Sabores (Flavors)"),
        const Text("Configuraciones para DEV, QA y PROD."),
        const SizedBox(height: 10),
        _buildExampleCard("Selector de Entorno", const FlavorSimulator()),
        const SizedBox(height: 50),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. ICON PREVIEWER
class IconPreviewer extends StatefulWidget {
  const IconPreviewer({super.key});
  @override
  State<IconPreviewer> createState() => _IconPreviewerState();
}
class _IconPreviewerState extends State<IconPreviewer> {
  Color _bg = Colors.blue;
  IconData _icon = Icons.rocket_launch;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _iconCard("Android (Adaptive)", true),
        _iconCard("iOS (Standard)", false),
      ]),
      const Divider(),
      const Text("Personalizar Branding:"),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: () => setState(() => _bg = Colors.blue), icon: const Icon(Icons.circle, color: Colors.blue)),
        IconButton(onPressed: () => setState(() => _bg = Colors.red), icon: const Icon(Icons.circle, color: Colors.red)),
        IconButton(onPressed: () => setState(() => _bg = Colors.black), icon: const Icon(Icons.circle, color: Colors.black)),
        const SizedBox(width: 20),
        IconButton(onPressed: () => setState(() => _icon = Icons.rocket_launch), icon: const Icon(Icons.rocket_launch)),
        IconButton(onPressed: () => setState(() => _icon = Icons.eco), icon: const Icon(Icons.eco)),
      ])
    ]);
  }

  Widget _iconCard(String platform, bool round) {
    return Column(children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(round ? 30 : 12), // Redondo o Cuadrado
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.2))],
        ),
        child: Icon(_icon, color: Colors.white, size: 30),
      ),
      const SizedBox(height: 5),
      Text(platform, style: const TextStyle(fontSize: 10))
    ]);
  }
}



// 2. SPLASH SIMULATOR
class SplashSimulator extends StatelessWidget {
  const SplashSimulator({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const _FakeSplash(),
            );
          },
          child: const Text("Lanzar App (Ver Splash)"),
        ),
      ),
    );
  }
}

class _FakeSplash extends StatefulWidget {
  const _FakeSplash();
  @override
  State<_FakeSplash> createState() => _FakeSplashState();
}
class _FakeSplashState extends State<_FakeSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if(mounted) Navigator.pop(context); // Cerrar splash
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.flutter_dash, size: 80, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// 3. FLAVOR SIMULATOR
class FlavorSimulator extends StatefulWidget {
  const FlavorSimulator({super.key});
  @override
  State<FlavorSimulator> createState() => _FlavorSimulatorState();
}
class _FlavorSimulatorState extends State<FlavorSimulator> {
  String _flavor = "dev";
  
  Map<String, Color> get _colors => {
    "dev": Colors.green,
    "qa": Colors.orange,
    "prod": Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _flavorBtn("DEV"), _flavorBtn("QA"), _flavorBtn("PROD")
      ]),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _colors[_flavor]!.withOpacity(0.1),
          border: Border.all(color: _colors[_flavor]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Text("App Name: MiApp ${_flavor.toUpperCase()}", style: TextStyle(fontWeight: FontWeight.bold, color: _colors[_flavor])),
          Text("API: https://api.$_flavor.miapp.com"),
          if (_flavor == 'dev') const Text("🐛 Debug Banner: Visible", style: TextStyle(fontSize: 10)),
        ]),
      )
    ]);
  }

  Widget _flavorBtn(String label) {
    final key = label.toLowerCase();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _flavor == key,
        onSelected: (v) => setState(() => _flavor = key),
        selectedColor: _colors[key]!.withOpacity(0.3),
      ),
    );
  }
}