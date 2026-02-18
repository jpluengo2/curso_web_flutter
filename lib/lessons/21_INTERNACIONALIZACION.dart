import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Lab21Internacionalizacion extends StatelessWidget {
  const Lab21Internacionalizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text("Laboratorio 21: Internacionalización (i18n)", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),

        // --- 1. TEXT TRANSLATION ---
        _buildSectionHeader("1. Traducción de Textos"),
        const Text("Simulación de cambio de idioma en tiempo real."),
        const SizedBox(height: 10),
        _buildExampleCard("Selector de Idioma", const TranslationDemo()),
        const SizedBox(height: 30),

        // --- 2. DATES FORMATTING ---
        _buildSectionHeader("2. Formato de Fechas (Intl)"),
        const Text("Uso de DateFormat para adaptar fechas a la región."),
        const SizedBox(height: 10),
        _buildExampleCard("Fechas Regionales", const DateFormatDemo()),
        const SizedBox(height: 30),

        // --- 3. CURRENCY FORMATTING ---
        _buildSectionHeader("3. Monedas y Números"),
        const Text("Formato de dinero y separadores decimales."),
        const SizedBox(height: 10),
        _buildExampleCard("Precios Internacionales", const CurrencyDemo()),
        const SizedBox(height: 30),

        // --- 4. PLURALS ---
        _buildSectionHeader("4. Plurales Inteligentes"),
        const Text("Manejo de singular/plural según el idioma."),
        const SizedBox(height: 10),
        _buildExampleCard("Contador de Artículos", const PluralDemo()),
        const SizedBox(height: 50),
      ],
    );
  }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), const Divider(thickness: 1)]));
  Widget _buildExampleCard(String title, Widget content) => Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))), Padding(padding: const EdgeInsets.all(15), child: content)]));
}

// 1. TRANSLATION DEMO
class TranslationDemo extends StatefulWidget {
  const TranslationDemo({super.key});
  @override
  State<TranslationDemo> createState() => _TranslationDemoState();
}
class _TranslationDemoState extends State<TranslationDemo> {
  String _locale = 'es';
  
  // Diccionario simulado (En apps reales esto son archivos .arb)
  final Map<String, Map<String, String>> _dictionary = {
    'es': {'hello': 'Hola Mundo', 'welcome': 'Bienvenido a Flutter'},
    'en': {'hello': 'Hello World', 'welcome': 'Welcome to Flutter'},
    'fr': {'hello': 'Bonjour le monde', 'welcome': 'Bienvenue sur Flutter'},
  };

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _langBtn('Español', 'es'),
        _langBtn('English', 'en'),
        _langBtn('Français', 'fr'),
      ]),
      const Divider(),
      Text(_dictionary[_locale]!['hello']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text(_dictionary[_locale]!['welcome']!, style: TextStyle(color: Colors.grey.shade600)),
    ]);
  }

  Widget _langBtn(String label, String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _locale == code,
        onSelected: (v) => setState(() => _locale = code),
      ),
    );
  }
}

// 2. DATE FORMAT DEMO
class DateFormatDemo extends StatelessWidget {
  const DateFormatDemo({super.key});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _dateRow("EE.UU (en_US)", DateFormat.yMMMMd('en_US').add_jm(), now),
      _dateRow("España (es_ES)", DateFormat.yMMMMd('es_ES').add_jm(), now),
      _dateRow("Reino Unido (en_GB)", DateFormat.yMMMMd('en_GB').add_jm(), now),
      _dateRow("Japón (ja_JP)", DateFormat.yMMMMd('ja_JP').add_jm(), now),
    ]);
  }
  Widget _dateRow(String label, DateFormat fmt, DateTime date) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(fmt.format(date))]));
}

// 3. CURRENCY DEMO
class CurrencyDemo extends StatelessWidget {
  const CurrencyDemo({super.key});
  @override
  Widget build(BuildContext context) {
    const amount = 12345.67;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _moneyRow("Dólar (USD)", NumberFormat.simpleCurrency(locale: 'en_US'), amount),
      _moneyRow("Euro (EUR)", NumberFormat.simpleCurrency(locale: 'es_ES'), amount),
      _moneyRow("Yen (JPY)", NumberFormat.simpleCurrency(locale: 'ja_JP'), amount),
      _moneyRow("Peso Col (COP)", NumberFormat.simpleCurrency(locale: 'es_CO'), amount),
    ]);
  }
  Widget _moneyRow(String label, NumberFormat fmt, double amount) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(fmt.format(amount), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))]));
}

// 4. PLURAL DEMO
class PluralDemo extends StatefulWidget {
  const PluralDemo({super.key});
  @override
  State<PluralDemo> createState() => _PluralDemoState();
}
class _PluralDemoState extends State<PluralDemo> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: () => setState(() => _count = _count > 0 ? _count - 1 : 0), icon: const Icon(Icons.remove)),
        Text("$_count", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add)),
      ]),
      const SizedBox(height: 10),
      Text(
        // Intl.plural es la magia aquí
        Intl.plural(
          _count,
          zero: 'No tienes artículos en el carrito.',
          one: 'Tienes 1 artículo.',
          other: 'Tienes $_count artículos.',
          name: "itemCount",
          args: [_count],
          desc: "Description of item count",
        ),
        style: const TextStyle(color: Colors.blue, fontSize: 16),
      )
    ]);
  }
}