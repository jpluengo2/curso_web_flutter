# Diseño Responsive y Safe Area en Flutter - Guía Completa

## 📚 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Conceptos fundamentales](#conceptos-fundamentales)
3. [MediaQuery](#mediaquery)
4. [LayoutBuilder](#layoutbuilder)
5. [SafeArea](#safearea)
6. [Responsive Widgets](#responsive-widgets)
7. [Breakpoints](#breakpoints)
8. [Orientación de pantalla](#orientación-de-pantalla)
9. [Patrones responsive](#patrones-responsive)
10. [Ejemplos prácticos](#ejemplos-prácticos)
11. [Mejores prácticas](#mejores-prácticas)

---

## Introducción

Un diseño responsive es aquel que se adapta a cualquier tamaño de pantalla: desde dispositivos pequeños (teléfono) hasta grandes (tablet o web).

### ¿Por qué es importante?
- **Múltiples dispositivos**: teléfonos, tablets, web, escritorio
- **Orientaciones**: portrait (vertical) y landscape (horizontal)
- **Usuarios diversos**: experiencia consistente en todos los dispositivos
- **Futura compatibilidad**: soportar nuevas resoluciones

### Principios básicos
1. **Flexibilidad**: componentes que se adapten
2. **Flujo**: contenido que reajusta automáticamente
3. **Proporción**: tamaños relativos, no absolutos
4. **Seguridad**: evitar notches, gestures bar (SafeArea)

---

## Conceptos Fundamentales

### Píxeles físicos vs Píxeles lógicos

```dart
// Flutter usa píxeles lógicos (dp - density independent pixels)
// Un píxel lógico = 1 píxel en dispositivo de 160 dpi
// En retina (326 dpi) = 2 píxeles físicos

// Todos los valores en Flutter son automáticamente escalados
Container(
  width: 100, // 100 píxeles lógicos (adapta automáticamente)
  height: 100,
  color: Colors.blue,
)
```

### Constraints (Restricciones)

Todo widget en Flutter tiene restricciones que le dicen:
- Ancho mínimo y máximo
- Alto mínimo y máximo

```dart
// Ejemplo de constraints
Container(
  constraints: BoxConstraints(
    minWidth: 0,      // Ancho mínimo
    maxWidth: 300,    // Ancho máximo
    minHeight: 0,     // Alto mínimo
    maxHeight: 200,   // Alto máximo
  ),
  color: Colors.blue,
)

// El widget respeta estos límites
```

---

## MediaQuery

### ¿Qué es MediaQuery?

Permite consultar información sobre el dispositivo actual: tamaño, densidad, orientación, etc.

```dart
import 'package:flutter/material.dart';

// Obtener información del dispositivo
class MediaQueryExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tamaño de la pantalla
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Padding (insets) - áreas no disponibles
    final padding = MediaQuery.of(context).padding;
    final viewInsets = MediaQuery.of(context).viewInsets;

    // Orientación
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isLandscape = orientation == Orientation.landscape;

    // Densidad de píxeles
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Factor de escala del texto
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(title: Text('MediaQuery Info')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ancho: $screenWidth'),
              Text('Alto: $screenHeight'),
              Text('Orientación: $orientation'),
              Text('Densidad: $devicePixelRatio'),
              Text('Escala texto: $textScaleFactor'),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Adaptar tamaño según pantalla

```dart
class ResponsiveSize extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Tamaño del contenedor según ancho
    double containerWidth;
    if (screenWidth < 600) {
      containerWidth = screenWidth * 0.9; // 90% en móviles
    } else if (screenWidth < 900) {
      containerWidth = screenWidth * 0.8; // 80% en tablets
    } else {
      containerWidth = screenWidth * 0.6; // 60% en desktop
    }

    return Center(
      child: Container(
        width: containerWidth,
        height: 200,
        color: Colors.blue,
        child: Center(
          child: Text('Ancho responsivo: $containerWidth'),
        ),
      ),
    );
  }
}
```

### Función auxiliar para obtener MediaQuery

```dart
class DeviceInfo {
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getScreenWidth(BuildContext context) {
    return getScreenSize(context).width;
  }

  static double getScreenHeight(BuildContext context) {
    return getScreenSize(context).height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 900;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) {
      return EdgeInsets.all(8);
    } else if (width < 900) {
      return EdgeInsets.all(16);
    } else {
      return EdgeInsets.all(24);
    }
  }
}

// Uso
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmall = DeviceInfo.isSmallScreen(context);
    final padding = DeviceInfo.getResponsivePadding(context);

    return Scaffold(
      body: Padding(
        padding: padding,
        child: isSmall
          ? Column(children: [...]) // Móvil
          : Row(children: [...]),   // Tablet/Desktop
      ),
    );
  }
}
```

---

## LayoutBuilder

### ¿Qué es LayoutBuilder?

Construye widgets basándose en constraints disponibles.

```dart
class LayoutBuilderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints contiene maxWidth, maxHeight, etc.
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        return Container(
          width: maxWidth,
          height: maxHeight,
          color: Colors.blue,
          child: Center(
            child: Text('Ancho: $maxWidth, Alto: $maxHeight'),
          ),
        );
      },
    );
  }
}
```

### Usar LayoutBuilder para diseños responsivos

```dart
class ResponsiveGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas
        int columnCount;
        if (constraints.maxWidth < 600) {
          columnCount = 1; // Móvil
        } else if (constraints.maxWidth < 900) {
          columnCount = 2; // Tablet
        } else {
          columnCount = 3; // Desktop
        }

        return GridView.count(
          crossAxisCount: columnCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          children: List.generate(
            12,
            (index) => Container(
              color: Colors.primaries[index % Colors.primaries.length],
              child: Center(
                child: Text('Item $index'),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### Comparación: MediaQuery vs LayoutBuilder

```dart
class ComparisonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Opción 1: MediaQuery (consulta pantalla completa)
        MediaQuery.of(context).size.width < 600
          ? ListViewLayout()
          : GridViewLayout(),

        // Opción 2: LayoutBuilder (consulta constraints disponibles)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth < 600
                ? ListViewLayout()
                : GridViewLayout();
            },
          ),
        ),
      ],
    );
  }
}

// LayoutBuilder es mejor para widgets dentro de otros widgets
// MediaQuery es mejor para la pantalla completa
```

---

## SafeArea

### ¿Qué es SafeArea?

Evita que contenido se superponga con:
- **Notch** (muesca en la parte superior)
- **Status bar** (barra de estado)
- **Bottom gesture bar** (barra de gestos inferior)
- **Rounded corners** (bordes redondeados)

```dart
// Sin SafeArea - contenido puede quedar oculto
Scaffold(
  body: Container(
    color: Colors.red,
    child: Text('Este texto puede estar bajo el notch'),
  ),
)

// Con SafeArea - contenido está protegido
Scaffold(
  body: SafeArea(
    child: Container(
      color: Colors.red,
      child: Text('Este texto está seguro'),
    ),
  ),
)
```

### Opciones de SafeArea

```dart
class SafeAreaOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Controlar qué bordes se protegen
      top: true,        // Protege status bar y notch
      bottom: true,     // Protege gesture bar
      left: true,       // Protege lado izquierdo
      right: true,      // Protege lado derecho
      
      // Mínimo space (padding mínimo)
      minimum: EdgeInsets.all(8),
      
      child: Scaffold(
        body: Column(
          children: [
            Container(color: Colors.red, height: 100),
            Expanded(child: Container(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
```

### Casos de uso de SafeArea

```dart
// 1. Pantalla completa
class FullScreenSafe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Safe')),
        body: ListView(...),
      ),
    );
  }
}

// 2. Solo para contenido personalizado
class CustomSafe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi App')),
      body: SafeArea(
        top: false, // AppBar maneja su propio padding
        child: Container(
          color: Colors.blue,
          child: Text('Contenido seguro'),
        ),
      ),
    );
  }
}

// 3. Con mínimo padding
class MinimumPaddingSafe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(16),
      child: Center(
        child: Text('Mínimo 16 píxeles de padding'),
      ),
    );
  }
}
```

---

## Responsive Widgets

### Flexible - Distribuir espacio disponible

```dart
class FlexibleExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Flexible es como Expanded, pero no requiere llenar todo
        Flexible(
          flex: 1, // Ocupa 1 parte de 5 totales (1/5)
          child: Container(color: Colors.red),
        ),
        Flexible(
          flex: 2, // Ocupa 2 partes (2/5)
          child: Container(color: Colors.blue),
        ),
        Flexible(
          flex: 2, // Ocupa 2 partes (2/5)
          child: Container(color: Colors.green),
        ),
      ],
    );
  }
}
```

### Expanded - Llenar espacio disponible

```dart
class ExpandedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          color: Colors.red,
        ),
        // Expanded rellena todo el espacio restante
        Expanded(
          child: Container(
            color: Colors.blue,
            child: Center(child: Text('Expanded')),
          ),
        ),
      ],
    );
  }
}
```

### Spacer - Espacio flexible

```dart
class SpacerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 50, height: 50, color: Colors.red),
        Spacer(flex: 1), // Espacio flexible (proporción 1)
        Container(width: 50, height: 50, color: Colors.blue),
        Spacer(flex: 2), // Espacio flexible (proporción 2)
        Container(width: 50, height: 50, color: Colors.green),
      ],
    );
  }
}
```

### AspectRatio - Mantener proporción

```dart
class AspectRatioExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // Mantiene proporción 16:9
      child: Container(
        color: Colors.blue,
        child: Image.network(
          'https://example.com/image.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Ejemplo: Galería con proporción constante
class ResponsiveGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1, // Cuadrados
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.primaries[index % Colors.primaries.length],
          ),
        );
      },
    );
  }
}
```

### FractionallySizedBox - Tamaño como porcentaje

```dart
class FractionallySizedBoxExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,  // 80% del ancho del parent
        heightFactor: 0.6, // 60% del alto del parent
        child: Container(
          color: Colors.blue,
          child: Center(child: Text('80% x 60%')),
        ),
      ),
    );
  }
}
```

---

## Breakpoints

### Definir breakpoints consistentes

```dart
class ScreenSize {
  // Definir puntos de quiebre
  static const double mobile = 600;      // < 600: móvil
  static const double tablet = 900;      // 600-900: tablet
  static const double desktop = 1200;    // > 900: desktop

  // Enumerar tipos de pantalla
  static ScreenType getScreenType(double width) {
    if (width < mobile) return ScreenType.mobile;
    if (width < tablet) return ScreenType.tablet;
    if (width < desktop) return ScreenType.largeTablet;
    return ScreenType.desktop;
  }

  // Obtener tipo de pantalla desde context
  static ScreenType getScreenTypeFromContext(BuildContext context) {
    return getScreenType(MediaQuery.of(context).size.width);
  }

  // Helpers booleanos
  static bool isMobile(BuildContext context) {
    return getScreenTypeFromContext(context) == ScreenType.mobile;
  }

  static bool isTablet(BuildContext context) {
    final screenType = getScreenTypeFromContext(context);
    return screenType == ScreenType.tablet ||
        screenType == ScreenType.largeTablet;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenTypeFromContext(context) == ScreenType.desktop;
  }
}

enum ScreenType {
  mobile,
  tablet,
  largeTablet,
  desktop,
}
```

### Usar breakpoints en widgets

```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenType = ScreenSize.getScreenTypeFromContext(context);

    switch (screenType) {
      case ScreenType.mobile:
        return MobileLayout();
      case ScreenType.tablet:
      case ScreenType.largeTablet:
        return TabletLayout();
      case ScreenType.desktop:
        return DesktopLayout();
    }
  }
}

class MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(),
          Expanded(child: MainContent()),
          BottomNav(),
        ],
      ),
    );
  }
}

class TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(child: MainContent()),
        ],
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          WideSidebar(),
          Expanded(child: MainContent()),
          RightPanel(),
        ],
      ),
    );
  }
}
```

---

## Orientación de Pantalla

### Detectar cambio de orientación

```dart
class OrientationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(title: Text('Orientación')),
      body: orientation == Orientation.portrait
        ? PortraitLayout()
        : LandscapeLayout(),
    );
  }
}

class PortraitLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 200, color: Colors.red),
        Container(height: 200, color: Colors.blue),
        Container(height: 200, color: Colors.green),
      ],
    );
  }
}

class LandscapeLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(color: Colors.red)),
        Expanded(child: Container(color: Colors.blue)),
        Expanded(child: Container(color: Colors.green)),
      ],
    );
  }
}
```

### Usar OrientationBuilder

```dart
class OrientationBuilderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return GridView.count(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
          children: List.generate(12, (index) {
            return Container(
              margin: EdgeInsets.all(8),
              color: Colors.primaries[index % Colors.primaries.length],
              child: Center(child: Text('Item $index')),
            );
          }),
        );
      },
    );
  }
}
```

### Forzar orientación

```dart
import 'package:flutter/services.dart';

class OrientationControl {
  // Forzar portrait
  static void setPortraitOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Forzar landscape
  static void setLandscapeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Permitir todas las orientaciones
  static void setAllOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

// Uso en main()
void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MyApp());
  });
}
```

---

## Patrones Responsive

### Patrón 1: Columna en móvil, Fila en tablet

```dart
class ResponsiveRowColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final children = [
      Container(
        color: Colors.red,
        child: Text('Panel 1'),
      ),
      Container(
        color: Colors.blue,
        child: Text('Panel 2'),
      ),
    ];

    return isMobile
      ? Column(children: children)
      : Row(children: children.map((child) => Expanded(child: child)).toList());
  }
}
```

### Patrón 2: Lista en móvil, Grid en tablet

```dart
class ResponsiveListGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return screenWidth < 600
      ? ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return ListTile(title: Text('Item $index'));
          },
        )
      : GridView.count(
          crossAxisCount: screenWidth < 900 ? 2 : 3,
          children: List.generate(20, (index) {
            return Container(
              margin: EdgeInsets.all(8),
              color: Colors.blue,
              child: Center(child: Text('Item $index')),
            );
          }),
        );
  }
}
```

### Patrón 3: Master-Detail (Tablet/Desktop)

```dart
class MasterDetailLayout extends StatefulWidget {
  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Móvil: mostrar lista o detalles
      return selectedIndex == -1
        ? MasterList(
            onSelect: (index) {
              setState(() => selectedIndex = index);
            },
          )
        : DetailView(
            index: selectedIndex,
            onBack: () {
              setState(() => selectedIndex = -1);
            },
          );
    } else {
      // Tablet/Desktop: master y detail lado a lado
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: MasterList(
              onSelect: (index) {
                setState(() => selectedIndex = index);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: selectedIndex >= 0
              ? DetailView(index: selectedIndex, onBack: () {})
              : Center(child: Text('Selecciona un elemento')),
          ),
        ],
      );
    }
  }
}

class MasterList extends StatelessWidget {
  final Function(int) onSelect;

  const MasterList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          onTap: () => onSelect(index),
        );
      },
    );
  }
}

class DetailView extends StatelessWidget {
  final int index;
  final VoidCallback onBack;

  const DetailView({required this.index, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile
        ? AppBar(
            leading: BackButton(onPressed: onBack),
            title: Text('Detalles'),
          )
        : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Detalles del Item $index'),
              SizedBox(height: 100, child: Container(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Ejemplos Prácticos

### Ejemplo 1: Dashboard Responsive

```dart
class ResponsiveDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Determinar número de columnas
            final columns = constraints.maxWidth < 600
              ? 1
              : constraints.maxWidth < 900
                ? 2
                : 3;

            return GridView.count(
              crossAxisCount: columns,
              padding: EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                DashboardCard(title: 'Ventas', value: '1,234'),
                DashboardCard(title: 'Usuarios', value: '567'),
                DashboardCard(title: 'Ingresos', value: '\$9,876'),
                DashboardCard(title: 'Comentarios', value: '234'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
```

### Ejemplo 2: Blog Responsive con Sidebar

```dart
class ResponsiveBlog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Mi Blog')),
        drawer: isMobile ? AppDrawer() : null,
        body: Row(
          children: [
            if (!isMobile)
              SizedBox(
                width: 250,
                child: AppDrawer(),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BlogPost(
                        title: 'Post 1',
                        content: 'Contenido del post 1',
                      ),
                      SizedBox(height: 24),
                      BlogPost(
                        title: 'Post 2',
                        content: 'Contenido del post 2',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: ListView(
        children: [
          DrawerHeader(child: Text('Menú')),
          ListTile(title: Text('Inicio')),
          ListTile(title: Text('Blog')),
          ListTile(title: Text('Sobre mí')),
          ListTile(title: Text('Contacto')),
        ],
      ),
    );
  }
}

class BlogPost extends StatelessWidget {
  final String title;
  final String content;

  const BlogPost({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
```

### Ejemplo 3: Carrito de compras responsive

```dart
class ResponsiveCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final items = [
      CartItem(name: 'Producto 1', price: 29.99, quantity: 2),
      CartItem(name: 'Producto 2', price: 49.99, quantity: 1),
      CartItem(name: 'Producto 3', price: 19.99, quantity: 3),
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Carrito')),
        body: isMobile
          ? Column(
              children: [
                Expanded(
                  child: CartItemsList(items: items),
                ),
                CartSummary(items: items),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CartItemsList(items: items),
                ),
                Expanded(
                  flex: 1,
                  child: CartSummary(items: items),
                ),
              ],
            ),
      ),
    );
  }
}

class CartItem {
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
}

class CartItemsList extends StatelessWidget {
  final List<CartItem> items;

  const CartItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${item.price.toStringAsFixed(2)}'),
                      Text('Cantidad: ${item.quantity}'),
                    ],
                  ),
                ),
                Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CartSummary extends StatelessWidget {
  final List<CartItem> items;

  const CartSummary({required this.items});

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(left: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Impuestos:'),
              Text('\$${tax.toStringAsFixed(2)}'),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: Text('Comprar'),
          ),
        ],
      ),
    );
  }
}
```

---

## Mejores Prácticas

### 1. Usar constantes para breakpoints

```dart
// ✅ Bien
class BreakpointsConstants {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// ❌ Evitar
if (width < 600) { ... }
if (width < 900) { ... }
```

### 2. Crear helpers reutilizables

```dart
// ✅ Bien
extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width < 900;
  bool get isDesktop => MediaQuery.of(this).size.width >= 900;
}

// Uso
if (context.isMobile) { ... }

// ❌ Evitar
if (MediaQuery.of(context).size.width < 600) { ... }
```

### 3. Preferir LayoutBuilder a MediaQuery cuando sea posible

```dart
// ✅ Bien (para widgets anidados)
LayoutBuilder(
  builder: (context, constraints) {
    return Column(
      children: [
        Container(width: constraints.maxWidth),
      ],
    );
  },
)

// ✅ Bien (para pantalla completa)
MediaQuery.of(context).size.width < 600
  ? MobileLayout()
  : DesktopLayout()
```

### 4. Usar SafeArea apropiadamente

```dart
// ✅ Bien
SafeArea(
  child: Scaffold(
    body: CustomContent(),
  ),
)

// ❌ Evitar nesting excesivo
SafeArea(
  child: Scaffold(
    body: SafeArea(
      child: Text('Anidado dos veces'),
    ),
  ),
)
```

### 5. Mantener proporción de aspectos

```dart
// ✅ Bien
GridView(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1, // Especificar proporción
  ),
)

// ❌ Evitar
GridView(
  children: [
    Image(height: 200), // Alto fijo, ancho variable
  ],
)
```

### 6. Testear en múltiples tamaños

```dart
// En pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

// En test/responsive_test.dart
void main() {
  testWidgets('Layout responsive en móvil', (WidgetTester tester) async {    
    tester.view.physicalSize = const Size(600, 800); // Simula tamaño móvil
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MyApp());
    
    expect(find.byType(Column), findsOneWidget); // Móvil usa Column
  });

  testWidgets('Layout responsive en tablet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800); // Simula tamaño tablet
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    
    await tester.pumpWidget(MyApp());
    
    expect(find.byType(Row), findsOneWidget); // Tablet usa Row
  });
}
```

### 7. Considerar text scale factor

```dart
// Algunos usuarios ajustan tamaño de texto en settings
// Flutter respeta esto automáticamente, pero verifica

@override
Widget build(BuildContext context) {
  final textScale = MediaQuery.of(context).textScaleFactor;
  
  return Text(
    'Contenido',
    style: TextStyle(fontSize: 14 * textScale), // Escala automáticamente
  );
}

// O usar textScaleFactor en themes
ThemeData(
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontSize: 14),
    // Flutter ajusta automáticamente según preferencias
  ),
)
```

### 8. Padding responsive

```dart
// ✅ Bien
class ResponsivePadding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width < 600 ? 8.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(),
    );
  }
}

// ✅ Alternativa con extension
extension EdgeInsetsExtension on BuildContext {
  EdgeInsets get responsivePadding {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) return EdgeInsets.all(8);
    if (width < 900) return EdgeInsets.all(16);
    return EdgeInsets.all(24);
  }
}

// Uso
Padding(padding: context.responsivePadding, child: ...)
```

---

## Checklist de Diseño Responsive

- ✅ Usar SafeArea en pantallas completas
- ✅ Definir breakpoints consistentes
- ✅ Probar en móvil, tablet y desktop
- ✅ Probar en portrait y landscape
- ✅ Verificar con diferentes text scales
- ✅ Usar Flexible/Expanded en lugar de tamaños fijos
- ✅ Usar AspectRatio para mantener proporciones
- ✅ Implementar master-detail en tablet
- ✅ Considerar drawer vs sidebar
- ✅ Testear en dispositivos reales

---

Conceptos Relacionados:
- 01_FUNDAMENTOS_WIDGETS_BASICOS
- 04_LISTVIEW_SCROLLVIEW
- 06_SCAFFOLD_NAVEGACION
- 08_TEMAS_THEMES
- EJERCICIOS_09_RESPONSIVE_DESIGN

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio**
