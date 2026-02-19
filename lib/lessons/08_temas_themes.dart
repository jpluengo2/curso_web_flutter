import 'package:flutter/material.dart';

class Lab08Themes extends StatelessWidget {
  const Lab08Themes({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el tema del contexto para los estilos principales
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 08: Temas y Estilos",
            textAlign: TextAlign.center,
            // MEJORA: Usar el color del tema para que se adapte
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // --- 1. COLOR SCHEME (TEORÍA: ColorScheme.fromSeed) ---
        _buildSectionHeader("1. ColorScheme y Semillas"),
        const Text("Material 3 genera paletas completas a partir de un solo color semilla."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Generador de Paletas Dinámicas",
          const ColorSchemeExplorer(),
        ),

        const SizedBox(height: 30),

        // --- 2. TIPOGRAFÍA (TEORÍA: TextTheme) ---
        _buildSectionHeader("2. Tipografía (TextTheme)"),
        const Text("Estilos de texto estandarizados en toda la app."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Escala Tipográfica Material 3",
          const TypographyDemo(),
        ),

        const SizedBox(height: 30),

        // --- 3. TEMAS DE COMPONENTES (TEORÍA: ButtonThemes, InputDeco) ---
        _buildSectionHeader("3. Personalización de Componentes"),
        const Text("Define la forma y color de botones e inputs globalmente."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Estilos Globales de Widgets",
          const ComponentThemeDemo(),
        ),

        const SizedBox(height: 30),

        // --- 4. MODO CLARO / OSCURO (TEORÍA: Brightness) ---
        _buildSectionHeader("4. Modo Claro y Oscuro"),
        const Text("Cambio de tema en tiempo real usando Brightness."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Simulador Light/Dark",
          const LightDarkSimulator(),
        ),

        const SizedBox(height: 30),

        // --- 5. CASO DE USO: MULTI-BRAND (TEORÍA: Casos prácticos) ---
        _buildSectionHeader("5. Caso Real: Multi-Marca"),
        const Text("Cambia la identidad visual completa de la app con un clic."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Selector de Marca (Branding)",
          const BrandThemeDemo(),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder( // Usamos Builder para obtener el contexto correcto
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MEJORA: Usar el color primario del tema
              Text(title, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              const Divider(thickness: 1),
            ],
          ),
        );
      }
    );
  }

  Widget _buildExampleCard(String title, Widget content) {
    return Builder( // Usamos Builder para obtener el contexto correcto
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            // MEJORA: Usar el color de la tarjeta del tema para adaptarse al modo oscuro/claro
            color: theme.cardColor,
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  // MEJORA: Usar un color de superficie del tema
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                // MEJORA: Usar un color de texto del tema
                child: Text(title, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
              ),
              Padding(padding: const EdgeInsets.all(15), child: content),
            ],
          ),
        );
      }
    );
  }
}

// ==========================================
// DEMOS INTERACTIVOS
// ==========================================

// 1. COLOR SCHEME EXPLORER
class ColorSchemeExplorer extends StatefulWidget {
  const ColorSchemeExplorer({super.key});
  @override
  State<ColorSchemeExplorer> createState() => _ColorSchemeExplorerState();
}

class _ColorSchemeExplorerState extends State<ColorSchemeExplorer> {
  Color _seedColor = Colors.blue;

  final List<Color> _seeds = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    // Generamos el esquema al vuelo basado en la selección
    final theme = Theme.of(context);
    final scheme = ColorScheme.fromSeed(seedColor: _seedColor);

    return Column(
      children: [
        const Text("Selecciona un color semilla:", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),
        // MEJORA: Usar Wrap en lugar de Row para evitar overflow en anchos pequeños.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0, // Espacio horizontal entre círculos
          runSpacing: 8.0, // Espacio vertical si hay más de una línea
          children: _seeds.map((color) {
            return GestureDetector(
              onTap: () => setState(() => _seedColor = color),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  // MEJORA: El borde de selección ahora usa un color del tema
                  border: _seedColor == color ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null,
                  boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text("Paleta Generada (Material 3):", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // Visualización de la paleta
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              _buildColorRow("Primary", scheme.primary, scheme.onPrimary),
              _buildColorRow("Primary Container", scheme.primaryContainer, scheme.onPrimaryContainer),
              _buildColorRow("Secondary", scheme.secondary, scheme.onSecondary),
              _buildColorRow("Secondary Container", scheme.secondaryContainer, scheme.onSecondaryContainer),
              _buildColorRow("Tertiary", scheme.tertiary, scheme.onTertiary),
              _buildColorRow("Error", scheme.error, scheme.onError),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow(String label, Color bg, Color text) {
    return Container(
      height: 40,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MEJORA: Expanded para que el texto del label ocupe el espacio disponible
          // y no cause overflow con el código hexadecimal.
          Expanded(child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12))),
          Text("#${bg.value.toRadixString(16).substring(2).toUpperCase()}", style: TextStyle(color: text.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }
}

// 2. TYPOGRAPHY DEMO
class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el tema actual del contexto para mostrar los estilos reales
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // MEJORA: El borde ahora usa un color del tema
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)), 
        borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Headline Large", style: textTheme.headlineLarge?.copyWith(fontSize: 24)),
          Text("Headline Medium", style: textTheme.headlineMedium?.copyWith(fontSize: 20)),
          const Divider(),
          Text("Title Large", style: textTheme.titleLarge),
          Text("Title Medium", style: textTheme.titleMedium),
          Text("Title Small", style: textTheme.titleSmall),
          const Divider(),
          Text("Body Large: El texto principal de lectura debe ser claro y legible.", style: textTheme.bodyLarge),
          const SizedBox(height: 5),
          Text("Body Medium: Texto secundario o de soporte.", style: textTheme.bodyMedium),
          const SizedBox(height: 5),
          Text("Label Small: Metadatos / Captions", style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

// 3. COMPONENT THEME DEMO
class ComponentThemeDemo extends StatefulWidget {
  const ComponentThemeDemo({super.key});
  @override
  State<ComponentThemeDemo> createState() => _ComponentThemeDemoState();
}

class _ComponentThemeDemoState extends State<ComponentThemeDemo> {
  bool _useRoundedTheme = false;

  @override
  Widget build(BuildContext context) {
    // Definimos dos temas locales muy diferentes para ver el contraste
    final roundedTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.purple,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.purple.shade50,
      ),
    );

    final squareTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.orange,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero), // Bordes rectos
          elevation: 10,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
        filled: false,
      ),
    );

    return Column(
      children: [
        SwitchListTile(
          title: const Text("Estilo Redondeado vs Cuadrado"),
          subtitle: Text(_useRoundedTheme ? "Tema: Purple Rounded" : "Tema: Orange Squared"),
          value: _useRoundedTheme,
          onChanged: (v) => setState(() => _useRoundedTheme = v),
        ),
        const Divider(),
        // Theme widget inyecta el tema solo a sus hijos
        Theme(
          data: _useRoundedTheme ? roundedTheme : squareTheme,
          child: Builder( // Builder necesario para leer el nuevo contexto del tema
            builder: (innerContext) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // MEJORA: Usar colores del tema inyectado por el widget Theme
                  color: Theme.of(innerContext).cardColor,
                  border: Border.all(color: Theme.of(innerContext).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    const TextField(decoration: InputDecoration(labelText: "Input con Estilo del Tema")),
                    const SizedBox(height: 20),
                    // MEJORA: Usar Wrap para que los botones se apilen verticalmente si no hay espacio.
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16.0, // Espacio entre botones
                      runSpacing: 8.0,
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text("Botón Primario")),
                        OutlinedButton(onPressed: () {}, child: const Text("Secundario")),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FloatingActionButton.small(
                      onPressed: () {},
                      child: const Icon(Icons.palette),
                    )
                  ],
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}

// 4. LIGHT / DARK SIMULATOR
class LightDarkSimulator extends StatefulWidget {
  const LightDarkSimulator({super.key});
  @override
  State<LightDarkSimulator> createState() => _LightDarkSimulatorState();
}

class _LightDarkSimulatorState extends State<LightDarkSimulator> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    // Definimos temas locales
    final lightTheme = ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: Colors.blue);
    final darkTheme = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.blue);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny, size: 16),
            Switch(value: _isDark, onChanged: (v) => setState(() => _isDark = v)),
            const Icon(Icons.nights_stay, size: 16),
          ],
        ),
        const SizedBox(height: 10),
        // Mini app simulada
        Theme(
          data: _isDark ? darkTheme : lightTheme,
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              return Container(
                height: 250,
                decoration: BoxDecoration(
                  color: scheme.surface, // Color de fondo del tema
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Scaffold(
                  // Scaffold anidado para simular app completa
                  appBar: AppBar(title: const Text("Mi App"), elevation: 2),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bienvenido", style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text("Mensaje importante"),
                            subtitle: const Text("El modo oscuro ahorra batería."),
                            tileColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.thumb_up),
                            label: const Text("Me gusta"),
                            onPressed: () {},
                          ),
                        )
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}

// 5. BRAND THEME DEMO
class BrandThemeDemo extends StatefulWidget {
  const BrandThemeDemo({super.key});
  @override
  State<BrandThemeDemo> createState() => _BrandThemeDemoState();
}

class _BrandThemeDemoState extends State<BrandThemeDemo> {
  Color _brandColor = Colors.teal;
  String _brandName = "EcoMarket";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Selecciona una identidad de marca:"),
        const SizedBox(height: 10),
        // MEJORA: Usar Wrap para que los chips de marca se apilen si no caben.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.0, // Espacio entre chips
          children: [
            _brandBtn("Tech", Colors.blue, Colors.blue),
            _brandBtn("Eco", Colors.teal, Colors.teal),
            _brandBtn("Love", Colors.pink, Colors.pink),
            _brandBtn("Luxury", Colors.black87, Colors.amber),
          ],
        ),
        const SizedBox(height: 20),
        // Mini app con la marca seleccionada
        Theme(
          data: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: _brandColor,
            // Ejemplo de override específico
            appBarTheme: AppBarTheme(
              backgroundColor: _brandColor,
              foregroundColor: _brandColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
          ),
          child: Builder(
            builder: (context) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scaffold(
                  appBar: AppBar(title: Text("$_brandName App")),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, size: 50, color: _brandColor),
                        const SizedBox(height: 10),
                        Text("Identidad visual aplicada", style: TextStyle(color: _brandColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        FilledButton(onPressed: () {}, child: const Text("Comprar Ahora"))
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _brandBtn(String label, Color bg, Color seed) {
    // MEJORA: El color del texto se calcula para ser legible sobre cualquier fondo
    final textColor = bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return InkWell(
      onTap: () => setState(() {
        _brandColor = seed;
        _brandName = label;
      }),
      child: Chip(
        label: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
        backgroundColor: bg,
        padding: EdgeInsets.zero,
      ),
    );
  }
}