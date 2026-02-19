import 'package:flutter/material.dart';

class Lab16Testing extends StatelessWidget {
  const Lab16Testing({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 16: Testing", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
        const Card(color: Colors.lightBlueAccent, child: Padding(padding: EdgeInsets.all(8.0), child: Text("💡 CONCEPTO: Como no podemos ejecutar terminales aquí, este laboratorio es un 'Test Runner Visual' que ejecuta la lógica de tus tests y muestra los resultados.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)))),
        const SizedBox(height: 20),

        _buildSectionHeader("1. Unit Tests (Lógica Pura)"),
        const Text("Pruebas de funciones aisladas (Validadores, Calculadoras)."),
        const SizedBox(height: 10),
        _buildExampleCard("Runner de Tests Unitarios", const UnitTestRunner()),
        const SizedBox(height: 30),

        _buildSectionHeader("2. Widget Tests (UI)"),
        const Text("Simulación de encontrar widgets y verificar su presencia."),
        const SizedBox(height: 10),
        _buildExampleCard("Simulador de Widget Tester", const WidgetTestSim()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. UNIT TEST RUNNER
class UnitTestRunner extends StatefulWidget {
  const UnitTestRunner({super.key});
  @override
  State<UnitTestRunner> createState() => _UnitTestRunnerState();
}
class _UnitTestRunnerState extends State<UnitTestRunner> {
  List<String> logs = [];

  // La función a testear
  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  void runTests() {
    setState(() => logs = []);
    _expect("Email vacío devuelve false", isValidEmail(""), false);
    _expect("Email sin @ devuelve false", isValidEmail("hola.com"), false);
    _expect("Email válido devuelve true", isValidEmail("test@test.com"), true);
  }

  void _expect(String description, dynamic actual, dynamic expected) {
    bool pass = actual == expected;
    setState(() {
      logs.add("${pass ? '✅ PASS' : '❌ FAIL'}: $description");
      if (!pass) logs.add("   Esperado: $expected, Obtenido: $actual");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text("Función a testear: isValidEmail()", style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Container(
        height: 150,
        padding: const EdgeInsets.all(10),
        color: Colors.black,
        child: ListView.builder(itemCount: logs.length, itemBuilder: (_, i) => Text(logs[i], style: TextStyle(color: logs[i].contains('PASS') ? Colors.green : Colors.red, fontFamily: 'monospace'))),
      ),
      ElevatedButton(onPressed: runTests, child: const Text("Ejecutar 'flutter test'"))
    ]);
  }
}

// 2. WIDGET TEST SIMULATOR
class WidgetTestSim extends StatefulWidget {
  const WidgetTestSim({super.key});
  @override
  State<WidgetTestSim> createState() => _WidgetTestSimState();
}
class _WidgetTestSimState extends State<WidgetTestSim> {
  int _counter = 0;
  List<String> _testLogs = [];

  void _runWidgetTest() async {
    setState(() { _counter = 0; _testLogs = ["🚀 Arrancando WidgetTester..."]; });
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Paso 1: Pump
    setState(() => _testLogs.add("Step 1: pumpWidget(CounterApp)"));
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Paso 2: Verify 0
    if (_counter == 0) {
      setState(() => _testLogs.add("✅ Expect: encuentra texto '0'"));
    } else {
      setState(() => _testLogs.add("❌ Fail: no encuentra '0'"));
    }
    
    // Paso 3: Tap
    setState(() {
      _counter++;
      _testLogs.add("Step 2: tap(find.byIcon(Icons.add))");
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Paso 4: Verify 1
    if (_counter == 1) {
      setState(() => _testLogs.add("✅ Expect: encuentra texto '1'"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        const Text("App:"),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
          child: Row(children: [Text("Count: $_counter"), const SizedBox(width: 10), const Icon(Icons.add_circle, color: Colors.blue)]),
        )
      ]),
      const Divider(),
      Container(
        height: 120,
        width: double.infinity,
        color: Colors.grey.shade900,
        padding: const EdgeInsets.all(8),
        child: ListView.builder(itemCount: _testLogs.length, itemBuilder: (_, i) => Text(_testLogs[i], style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 11))),
      ),
      ElevatedButton(onPressed: _runWidgetTest, child: const Text("Ejecutar Widget Test"))
    ]);
  }
}