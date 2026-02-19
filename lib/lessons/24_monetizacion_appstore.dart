import 'package:flutter/material.dart';

class Lab24Monetizacion extends StatelessWidget {
  const Lab24Monetizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 24: Monetización", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. IAP ---
        _buildSectionHeader("1. In-App Purchases (IAP)"),
        const Text("Simulación de tienda de productos digitales."),
        const SizedBox(height: 10),
        _buildExampleCard("Tienda de Gemas", const IAPSimulator()),
        const SizedBox(height: 30),

        // --- 2. ADS ---
        _buildSectionHeader("2. Publicidad (Ads)"),
        const Text("Simulación de espacios publicitarios (Banner & Interstitial)."),
        const SizedBox(height: 10),
        _buildExampleCard("AdMob Simulator", const AdsSimulator()),
        const SizedBox(height: 30),

        // --- 3. SUBSCRIPCIONES ---
        _buildSectionHeader("3. Modelo de Suscripción"),
        const Text("Gestión de estados Premium/Free."),
        const SizedBox(height: 10),
        _buildExampleCard("Paywall (Muro de Pago)", const SubscriptionDemo()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. IAP SIMULATOR
class IAPSimulator extends StatefulWidget {
  const IAPSimulator({super.key});
  @override
  State<IAPSimulator> createState() => _IAPSimulatorState();
}
class _IAPSimulatorState extends State<IAPSimulator> {
  int _gems = 0;
  
  void _buy(int amount) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conectando con Store... Compra Exitosa ✅")));
    setState(() => _gems += amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.diamond, color: Colors.blue), Text(" $_gems")]),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.local_offer, color: Colors.orange),
        title: const Text("Puñado de Gemas (x10)"),
        subtitle: const Text("0.99 €"),
        trailing: ElevatedButton(onPressed: () => _buy(10), child: const Text("Comprar")),
      ),
      ListTile(
        leading: const Icon(Icons.local_offer, color: Colors.purple),
        title: const Text("Cofre de Gemas (x100)"),
        subtitle: const Text("4.99 €"),
        trailing: ElevatedButton(onPressed: () => _buy(100), child: const Text("Comprar")),
      ),
    ]);
  }
}

// 2. ADS SIMULATOR
class AdsSimulator extends StatefulWidget {
  const AdsSimulator({super.key});
  @override
  State<AdsSimulator> createState() => _AdsSimulatorState();
}
class _AdsSimulatorState extends State<AdsSimulator> {
  bool _showInterstitial = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Contenido de la App..."),
      const SizedBox(height: 20),
      // Banner Ad
      Container(
        height: 50, width: double.infinity,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Text("BANNER AD (320x50)", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => setState(() => _showInterstitial = true),
        child: const Text("Mostrar Interstitial Ad"),
      ),
      if (_showInterstitial)
        Container(
          height: 200, width: double.infinity,
          color: Colors.black87,
          margin: const EdgeInsets.only(top: 10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("COMPRA NUESTRO PRODUCTO!!!", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => setState(() => _showInterstitial = false), child: const Text("Cerrar Anuncio (X)"))
          ]),
        )
    ]);
  }
}

// 3. SUBSCRIPTION DEMO
class SubscriptionDemo extends StatefulWidget {
  const SubscriptionDemo({super.key});
  @override
  State<SubscriptionDemo> createState() => _SubscriptionDemoState();
}
class _SubscriptionDemoState extends State<SubscriptionDemo> {
  bool _isPremium = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (_isPremium) 
        const Card(color: Colors.amber, child: ListTile(leading: Icon(Icons.star), title: Text("USUARIO PREMIUM"), subtitle: Text("Gracias por tu soporte")))
      else 
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.grey.shade100,
          child: Column(children: [
             const Text("🔒 Contenido Bloqueado"),
             const Text("Suscríbete para acceder a todo."),
             const SizedBox(height: 5),
             ElevatedButton(
               onPressed: () => setState(() => _isPremium = true),
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
               child: const Text("Suscribirse (9.99€/mes)"),
             )
          ]),
        ),
      const SizedBox(height: 10),
      if (_isPremium) TextButton(onPressed: () => setState(() => _isPremium = false), child: const Text("Cancelar Suscripción"))
    ]);
  }
}
