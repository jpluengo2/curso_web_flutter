import 'package:flutter/material.dart';
import 'dart:async';

class Lab17ManejoErrores extends StatelessWidget {
  const Lab17ManejoErrores({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 17: Manejo de Errores y Resiliencia", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. TRY-CATCH BÁSICO ---
        _buildSectionHeader("1. Try-Catch Básico"),
        const Text("Captura de excepciones síncronas para evitar crashes."),
        const SizedBox(height: 10),
        _buildExampleCard("División por Cero Segura", const TryCatchDemo()),
        const SizedBox(height: 30),

        // --- 2. ASYNC ERRORS ---
        _buildSectionHeader("2. Errores Asíncronos (Future/Stream)"),
        const Text("Manejo de fallos en operaciones que toman tiempo (Red, BD)."),
        const SizedBox(height: 10),
        _buildExampleCard("Simulador de Fallo de Red", const AsyncErrorDemo()),
        const SizedBox(height: 30),

        // --- 3. ERROR WIDGET (UI) ---
        _buildSectionHeader("3. Error Boundaries (UI)"),
        const Text("Reemplazo de la 'Pantalla Roja de la Muerte' por algo amigable."),
        const SizedBox(height: 10),
        _buildExampleCard("Widget con Fallo de Renderizado", const ErrorBoundaryDemo()),
        const SizedBox(height: 30),

        // --- 4. RETRY LOGIC ---
        _buildSectionHeader("4. Lógica de Reintento (Retry)"),
        const Text("Patrón de resiliencia: Si falla, vuelve a intentarlo."),
        const SizedBox(height: 10),
        _buildExampleCard("Botón con Auto-Retry", const RetryLogicDemo()),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. TRY-CATCH DEMO
class TryCatchDemo extends StatefulWidget {
  const TryCatchDemo({super.key});
  @override
  State<TryCatchDemo> createState() => _TryCatchDemoState();
}
class _TryCatchDemoState extends State<TryCatchDemo> {
  String _result = "Esperando cálculo...";
  final _ctrl = TextEditingController(text: "0");

  void _calculate() {
    try {
      int divisor = int.parse(_ctrl.text);
      // Provocamos el error
      int calc = 100 ~/ divisor; 
      setState(() => _result = "Resultado: $calc");
    } on IntegerDivisionByZeroException {
      setState(() => _result = "❌ Error: No se puede dividir por cero");
    } on FormatException {
      setState(() => _result = "❌ Error: Ingresa un número válido");
    } catch (e) {
      setState(() => _result = "❌ Error desconocido: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        const Text("100 / "),
        SizedBox(width: 50, child: TextField(controller: _ctrl, keyboardType: TextInputType.number)),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: _calculate, child: const Text("Calcular"))
      ]),
      const SizedBox(height: 10),
      Text(_result, style: TextStyle(color: _result.startsWith("❌") ? Colors.red : Colors.green, fontWeight: FontWeight.bold))
    ]);
  }
}

// 2. ASYNC ERROR DEMO
class AsyncErrorDemo extends StatefulWidget {
  const AsyncErrorDemo({super.key});
  @override
  State<AsyncErrorDemo> createState() => _AsyncErrorDemoState();
}
class _AsyncErrorDemoState extends State<AsyncErrorDemo> {
  String _status = "Listo";

  Future<void> _makeRequest() async {
    setState(() => _status = "⏳ Conectando...");
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Simulamos fallo aleatorio
      throw Exception("Timeout: El servidor no responde");
    } catch (e) {
      if (mounted) setState(() => _status = "🔥 Excepción capturada:\n$e");
    } finally {
      debugPrint("Limpieza de recursos completada");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(_status, textAlign: TextAlign.center),
      const SizedBox(height: 10),
      ElevatedButton(onPressed: _makeRequest, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100), child: const Text("Simular Petición Fallida"))
    ]);
  }
}

// 3. ERROR BOUNDARY DEMO (Custom Error Widget)
class ErrorBoundaryDemo extends StatefulWidget {
  const ErrorBoundaryDemo({super.key});
  @override
  State<ErrorBoundaryDemo> createState() => _ErrorBoundaryDemoState();
}
class _ErrorBoundaryDemoState extends State<ErrorBoundaryDemo> {
  bool _throwError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(title: const Text("Provocar Error de Renderizado"), value: _throwError, onChanged: (v) => setState(() => _throwError = v)),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: _throwError 
            ? const BuggyWidget() // Este widget falla intencionalmente
            : const Center(child: Text("Widget Sano", style: TextStyle(color: Colors.green))),
        )
      ],
    );
  }
}

class BuggyWidget extends StatelessWidget {
  const BuggyWidget({super.key});
  @override
  Widget build(BuildContext context) {
    // Definimos un ErrorWidget personalizado JUSTO ANTES de que ocurra el error
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: Colors.red.shade100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            Text("¡Ups! Algo salió mal.\n${details.exception}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 10)),
          ],
        ),
      );
    };
    
    // Provocamos error: RenderFlex overflow (muy común) o null check
    String? textoNulo;
    return Text(textoNulo!); // Error: Null check operator used on a null value
  }
}

// 4. RETRY LOGIC DEMO
class RetryLogicDemo extends StatefulWidget {
  const RetryLogicDemo({super.key});
  @override
  State<RetryLogicDemo> createState() => _RetryLogicDemoState();
}
class _RetryLogicDemoState extends State<RetryLogicDemo> {
  int _attempts = 0;
  String _msg = "";
  bool _loading = false;

  Future<void> _tryConnect() async {
    setState(() { _loading = true; _attempts = 0; _msg = "Iniciando..."; });
    
    bool success = false;
    while (_attempts < 3 && !success) {
      _attempts++;
      setState(() => _msg = "Intento $_attempts de 3...");
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Simula éxito solo en el intento 3
      if (_attempts == 3) {
        success = true;
      }
    }

    setState(() {
      _loading = false;
      _msg = success ? "✅ ¡Conectado al tercer intento!" : "❌ Falló tras 3 intentos";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(_msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      if (_loading) const LinearProgressIndicator(),
      const SizedBox(height: 10),
      ElevatedButton.icon(onPressed: _loading ? null : _tryConnect, icon: const Icon(Icons.refresh), label: const Text("Conectar con Reintento"))
    ]);
  }
}