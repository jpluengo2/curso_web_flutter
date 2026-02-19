# Widgets Avanzados en Flutter: Guía Completa

## Introducción a Widgets Avanzados

Más allá de los widgets básicos, Flutter proporciona widgets avanzados para casos complejos: navegación, layouts especiales, diálogos, popups, etc.

---

## 1. PageView (Paginación)

### 1.1 PageView Básico

```dart
class PageViewExample extends StatefulWidget {
  const PageViewExample({Key? key}) : super(key: key);

  @override
  State<PageViewExample> createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageView Example')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(
                    child: Text(
                      'Page ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Anterior'),
                ),
                Text('${_currentPage + 1} / 5'),
                ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Siguiente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 1.2 PageView con Indicadores

```dart
class PageViewWithIndicators extends StatefulWidget {
  const PageViewWithIndicators({Key? key}) : super(key: key);

  @override
  State<PageViewWithIndicators> createState() =>
      _PageViewWithIndicatorsState();
}

class _PageViewWithIndicatorsState extends State<PageViewWithIndicators> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.primaries[index % Colors.primaries.length],
                child: Center(
                  child: Text(
                    'Page ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          // Indicadores
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => Container(
                  width: _currentPage == index ? 30 : 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
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

## 2. WillPopScope (Control de Atrás)

### 2.1 Prevenir Salir

```dart
class WillPopScopeExample extends StatefulWidget {
  const WillPopScopeExample({Key? key}) : super(key: key);

  @override
  State<WillPopScopeExample> createState() => _WillPopScopeExampleState();
}

class _WillPopScopeExampleState extends State<WillPopScopeExample> {
  bool _hasChanges = false;

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true; // Permitir salir
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text('¿Descartar cambios?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (_hasChanges && !didPop) {
          final shouldExit = await _onWillPop();
          if (shouldExit && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('WillPopScope Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_hasChanges ? 'Hay cambios sin guardar' : 'Sin cambios'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _hasChanges = !_hasChanges);
                },
                child: const Text('Hacer cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 3. CustomScrollView y Sliver

### 3.1 CustomScrollView Básico

```dart
class CustomScrollViewExample extends StatelessWidget {
  const CustomScrollViewExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar (colapsable)
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Scroll App'),
              background: Container(
                color: Colors.blue,
                child: const Center(
                  child: Icon(
                    Icons.landscape,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // SliverList
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                  subtitle: Text('Descripción del item $index'),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3.2 SliverGrid

```dart
class SliverGridExample extends StatelessWidget {
  const SliverGridExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Grid Sliver'),
            expandedHeight: 150,
            pinned: true,
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Dialogs y BottomSheets

### 4.1 AlertDialog

```dart
void showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmación'),
      content: const Text('¿Estás seguro de continuar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Acción
          },
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}
```

### 4.2 BottomSheet

```dart
void showCustomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Opciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Eliminar'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
```

### 4.3 DraggableBottomSheet

```dart
class DraggableBottomSheetExample extends StatelessWidget {
  const DraggableBottomSheetExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Bottom Sheet')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Opción $index'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          child: const Text('Mostrar Bottom Sheet'),
        ),
      ),
    );
  }
}
```

---

## 5. Tooltip y Popover

### 5.1 Tooltip

```dart
class TooltipExample extends StatelessWidget {
  const TooltipExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tooltip Example')),
      body: Center(
        child: Tooltip(
          message: 'Este es un botón importante',
          child: ElevatedButton(
            onPressed: () => print('Presionado'),
            child: const Text('Presiona y mantén'),
          ),
        ),
      ),
    );
  }
}
```

### 5.2 PopupMenuButton

```dart
class PopupMenuExample extends StatelessWidget {
  const PopupMenuExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popup Menu'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Seleccionado: $value')),
              );
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Compartir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Text('Presiona el menú en la esquina superior derecha'),
      ),
    );
  }
}
```

---

## 6. ExpansionTile y ExpansionPanel

### 6.1 ExpansionTile

```dart
class ExpansionTileExample extends StatefulWidget {
  const ExpansionTileExample({Key? key}) : super(key: key);

  @override
  State<ExpansionTileExample> createState() => _ExpansionTileExampleState();
}

class _ExpansionTileExampleState extends State<ExpansionTileExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExpansionTile')),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Sección 1'),
            subtitle: const Text('Presiona para expandir'),
            children: [
              ListTile(
                title: const Text('Opción 1.1'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Opción 1.2'),
                onTap: () {},
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Sección 2'),
            children: [
              ListTile(
                title: const Text('Opción 2.1'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Opción 2.2'),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 6.2 ExpansionPanelList

```dart
class ExpansionPanelExample extends StatefulWidget {
  const ExpansionPanelExample({Key? key}) : super(key: key);

  @override
  State<ExpansionPanelExample> createState() => _ExpansionPanelExampleState();
}

class _ExpansionPanelExampleState extends State<ExpansionPanelExample> {
  List<bool> _isExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExpansionPanel')),
      body: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded[index] = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                title: Text('Panel 1'),
              );
            },
            body: const ListTile(
              title: Text('Contenido del panel 1'),
              subtitle: Text('Descripción detallada'),
            ),
            isExpanded: _isExpanded[0],
          ),
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                title: Text('Panel 2'),
              );
            },
            body: const ListTile(
              title: Text('Contenido del panel 2'),
              subtitle: Text('Descripción detallada'),
            ),
            isExpanded: _isExpanded[1],
          ),
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                title: Text('Panel 3'),
              );
            },
            body: const ListTile(
              title: Text('Contenido del panel 3'),
              subtitle: Text('Descripción detallada'),
            ),
            isExpanded: _isExpanded[2],
          ),
        ],
      ),
    );
  }
}
```

---

## 7. TabBarView

### 7.1 TabBar Avanzado

```dart
class AdvancedTabBarExample extends StatefulWidget {
  const AdvancedTabBarExample({Key? key}) : super(key: key);

  @override
  State<AdvancedTabBarExample> createState() => _AdvancedTabBarExampleState();
}

class _AdvancedTabBarExampleState extends State<AdvancedTabBarExample>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced TabBar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4.0,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Home Tab')),
          const Center(child: Text('Search Tab')),
          const Center(child: Text('Favorites Tab')),
          const Center(child: Text('Profile Tab')),
        ],
      ),
    );
  }
}
```

---

## 8. NavigationRail y NavigationDrawer

### 8.1 NavigationRail (Escritorio)

```dart
class NavigationRailExample extends StatefulWidget {
  const NavigationRailExample({Key? key}) : super(key: key);

  @override
  State<NavigationRailExample> createState() => _NavigationRailExampleState();
}

class _NavigationRailExampleState extends State<NavigationRailExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Favorites'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: Text('Índice seleccionado: $_selectedIndex'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 9. DataTable

### 9.1 Tabla de Datos

```dart
class DataTableExample extends StatefulWidget {
  const DataTableExample({Key? key}) : super(key: key);

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  List<bool> selected = List.generate(10, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DataTable Example')),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Estado')),
          ],
          rows: List.generate(
            10,
            (index) => DataRow(
              selected: selected[index],
              onSelectChanged: (bool? value) {
                setState(() {
                  selected[index] = value ?? false;
                });
              },
              cells: [
                DataCell(Text('Usuario $index')),
                DataCell(Text('user$index@example.com')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      index % 2 == 0 ? 'Activo' : 'Inactivo',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 10. Material 3 Widgets

### 10.1 SearchBar

```dart
class SearchBarExample extends StatefulWidget {
  const SearchBarExample({Key? key}) : super(key: key);

  @override
  State<SearchBarExample> createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<SearchBarExample> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SearchBar Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _controller,
              hintText: 'Buscar...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  ),
              ],
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Resultado ${index + 1}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
```

### 10.2 FilledButton

```dart
class FilledButtonExample extends StatelessWidget {
  const FilledButtonExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material 3 Buttons')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {},
              child: const Text('Filled Button'),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Tonal Button'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 11. Best Practices

✅ **DO's:**
- Usar widgets apropiados para cada caso
- Proporcionar feedback visual
- Implementar accesibilidad
- Manejar estados correctamente
- Optimizar renderizado

❌ **DON'Ts:**
- Anidar demasiados widgets
- Olvidar dispose en controllers
- Ignorar accesibilidad
- Crear widgets complejos sin separar en componentes

---

## 12. Ejercicios

### Ejercicio 1: Galería de Imágenes
Crear con PageView, indicadores y gestos

### Ejercicio 2: Formulario Dinámico
Crear con ExpansionTiles y validación

### Ejercicio 3: App de Notas
Crear con DataTable, diálogos y BottomSheet

---

Conceptos Relacionados:
- 02_STATEFUL_STATELESS_LIFECYCLE
- 04_LISTVIEW_SCROLLVIEW
- 10_ANIMACIONES
- 11_GESTURES_EVENTOS
- EJERCICIOS_18_WIDGETS_AVANZADOS

## Resumen

Los widgets avanzados proporcionan:
- ✅ Navegación compleja
- ✅ Layouts sofisticados
- ✅ Interactividad mejorada
- ✅ Experiencia de usuario profesional
