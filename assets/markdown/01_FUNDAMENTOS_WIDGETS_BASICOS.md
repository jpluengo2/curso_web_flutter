# Introducción a Widgets Básicos en Flutter

## ¿Qué es un Widget?

En Flutter, **todo es un widget**. Un widget es un elemento visual de la interfaz de usuario.

### Concepto Fundamental

```
Material Design → Flutter → Widgets
   (Diseño)      (Framework)  (Componentes)
```

Los widgets son:
- ✅ Los bloques de construcción
- ✅ Inmutables (no cambian)
- ✅ Composables (se combinan)
- ✅ Reactivos (responden a cambios)

---

## 1. Mi Primer App

### 1.1 Estructura Básica

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Primera App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hola Flutter'),
        ),
        body: const Center(
          child: Text('¡Bienvenido!'),
        ),
      ),
    );
  }
}
```

### 1.2 Componentes Principales

| Componente | Función |
|---|---|
| `MaterialApp` | App raíz |
| `Scaffold` | Layout base |
| `AppBar` | Barra superior |
| `body` | Contenido principal |
| `Center` | Centra widgets |
| `Text` | Texto |

---

## 2. StatelessWidget vs StatefulWidget

### 2.1 StatelessWidget (Inmutable)

Un `StatelessWidget` **no cambia**. Una vez creado, permanece igual.

```dart
class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Hola, soy un StatelessWidget',
      style: TextStyle(fontSize: 20),
    );
  }
}

// Usar
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: WelcomeWidget(),
        ),
      ),
    ),
  );
}
```

### 2.2 StatefulWidget (Mutable)

Un `StatefulWidget` **puede cambiar**. Tiene un estado que se puede modificar.

```dart
class Counter extends StatefulWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Contador: $count',
          style: const TextStyle(fontSize: 24),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: const Text('Incrementar'),
        ),
      ],
    );
  }
}

// Usar
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Counter(),
      ),
    ),
  );
}
```

### 2.3 Diferencia Visual

```
StatelessWidget              StatefulWidget
    ↓                             ↓
Construido una vez          Puede reconstruirse
No tiene estado              Tiene setState()
Inmutable                    Mutable
Más rápido                   Más flexible
```

---

## 3. Widgets de Texto

### 3.1 Text (Texto Simple)

```dart
class TextExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Texto básico
        const Text('Texto simple'),

        // Con estilos
        const Text(
          'Texto con estilos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),

        // Múltiples líneas
        const Text(
          'Este es un texto largo que puede ocupar '
          'múltiples líneas en la pantalla',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Alineación
        const Text(
          'Texto centrado',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

### 3.2 TextField (Entrada de Texto)

```dart
class TextInputExample extends StatefulWidget {
  @override
  State<TextInputExample> createState() => _TextInputExampleState();
}

class _TextInputExampleState extends State<TextInputExample> {
  final TextEditingController _controller = TextEditingController();
  String _inputText = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Input básico
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Escribe algo...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _inputText = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Input de contraseña
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Input de email
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Mostrar lo que escribió
          Text('Escribiste: $_inputText'),
        ],
      ),
    );
  }
}
```

---

## 4. Widgets de Botones

### 4.1 ElevatedButton (Botón principal)

```dart
class ButtonExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón básico
        ElevatedButton(
          onPressed: () {
            print('Botón presionado');
          },
          child: const Text('Presiona aquí'),
        ),

        const SizedBox(height: 16),

        // Botón con icono
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),

        const SizedBox(height: 16),

        // Botón deshabilitado
        const ElevatedButton(
          onPressed: null,
          child: Text('Deshabilitado'),
        ),

        const SizedBox(height: 16),

        // Botón con estilo personalizado
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () {},
          child: const Text('Botón personalizado'),
        ),
      ],
    );
  }
}
```

### 4.2 OutlinedButton (Botón secundario)

```dart
OutlinedButton(
  onPressed: () {},
  child: const Text('Botón secundario'),
)
```

### 4.3 TextButton (Botón texto)

```dart
TextButton(
  onPressed: () {},
  child: const Text('Enlace'),
)
```

### 4.4 FloatingActionButton (Botón flotante)

```dart
class FloatingButtonExample extends StatefulWidget {
  @override
  State<FloatingButtonExample> createState() => _FloatingButtonExampleState();
}

class _FloatingButtonExampleState extends State<FloatingButtonExample> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FloatingActionButton')),
      body: Center(
        child: Text('Presiones: $count'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            count++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 5. Widgets de Layout

### 5.1 Container (Contenedor universal)

```dart
class ContainerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container básico
        Container(
          width: 200,
          height: 100,
          color: Colors.blue,
          child: const Center(child: Text('Contenedor')),
        ),

        const SizedBox(height: 16),

        // Container con padding
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.green,
          child: const Text('Con padding'),
        ),

        const SizedBox(height: 16),

        // Container con borde
        Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('Con borde')),
        ),

        const SizedBox(height: 16),

        // Container con sombra
        Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(child: Text('Con sombra')),
        ),
      ],
    );
  }
}
```

### 5.2 Column (Columna)

```dart
class ColumnExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Elemento 1'),
        const SizedBox(height: 8),
        const Text('Elemento 2'),
        const SizedBox(height: 8),
        const Text('Elemento 3'),
      ],
    );
  }
}

// mainAxisAlignment: Alinea verticalmente (center, start, end, spaceBetween)
// crossAxisAlignment: Alinea horizontalmente (center, start, end, stretch)
```

### 5.3 Row (Fila)

```dart
class RowExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(Icons.home),
        const Icon(Icons.search),
        const Icon(Icons.settings),
      ],
    );
  }
}
```

### 5.4 Padding (Espaciado)

```dart
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    color: Colors.blue,
    child: const Text('Con padding'),
  ),
)

// También puedes usar:
// EdgeInsets.symmetric(horizontal: 16, vertical: 8)
// EdgeInsets.only(top: 16, left: 8)
// EdgeInsets.fromLTRB(10, 20, 30, 40)
```

### 5.5 SizedBox (Espaciador)

```dart
// Espacio horizontal
const SizedBox(width: 16)

// Espacio vertical
const SizedBox(height: 16)

// Con tamaño específico
SizedBox(
  width: 100,
  height: 100,
  child: Container(color: Colors.blue),
)
```

---

## 6. Widgets de Imagen

### 6.1 Image (Imagen simple)

```dart
class ImageExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Desde assets
        Image.asset('assets/mi_imagen.png'),

        const SizedBox(height: 16),

        // Desde URL
        Image.network(
          'https://via.placeholder.com/200',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),

        const SizedBox(height: 16),

        // Con placeholder
        FadeInImage.assetNetwork(
          placeholder: 'assets/placeholder.png',
          image: 'https://via.placeholder.com/200',
          width: 200,
          height: 200,
        ),
      ],
    );
  }
}
```

### 6.2 Icon (Icono)

```dart
class IconExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Icon(Icons.home),
        const Icon(Icons.search, color: Colors.blue),
        const Icon(Icons.settings, size: 32),
        Icon(
          Icons.favorite,
          color: Colors.red,
          size: 28,
        ),
      ],
    );
  }
}
```

---

## 7. Widgets de Scroll

### 7.1 ListView (Lista desplazable)

```dart
class ListViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (index) => 'Item $index');

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.circle),
          title: Text(items[index]),
          subtitle: const Text('Descripción'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            print('Presionaste ${items[index]}');
          },
        );
      },
    );
  }
}
```

### 7.2 GridView (Cuadrícula)

```dart
class GridViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.blue[100 * ((index % 9) + 1)],
          child: Center(
            child: Text('Item $index'),
          ),
        );
      },
    );
  }
}
```

---

## 8. Ejemplo Completo: App de Tareas

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tareas',
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> tasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        tasks.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
      ),
      body: Column(
        children: [
          // Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nueva tarea...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),

          // Lista de tareas
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTask(index),
                  ),
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

---

## 9. Best Practices

✅ **DO's:**
- Usar `const` cuando sea posible
- Estructurar widgets lógicamente
- Usar `StatefulWidget` solo cuando necesites cambios
- Nombrar widgets claramente
- Documentar widgets complejos

❌ **DON'Ts:**
- Anidar widgets innecesariamente
- Cambiar state sin `setState()`
- Crear listeners en `build()`
- Olvidar `dispose()` para controladores
- Ignorar temas de performance

---

## 10. Ejercicios Iniciales

### Ejercicio 1: Contador Simple
Crear un `StatefulWidget` que muestre un contador con botones +/-

### Ejercicio 2: Lista de Compras
Crear una app que permita agregar/eliminar items

### Ejercicio 3: Formulario
Crear un formulario con múltiples campos de entrada

### Ejercicio 4: Galería
Crear una grid de imágenes (usa placeholders)

---

## 11. Estructura Recomendada

```
lib/
├── main.dart              # Punto de entrada
├── screens/               # Pantallas principales
│   ├── home_screen.dart
│   └── details_screen.dart
├── widgets/               # Componentes reutilizables
│   ├── custom_button.dart
│   └── card_widget.dart
└── constants/             # Colores, estilos, etc
    └── app_constants.dart
```

---

## Resumen

En Flutter:
- ✅ **Todo es un widget**
- ✅ Usa `StatelessWidget` para lo inmutable
- ✅ Usa `StatefulWidget` para cambios
- ✅ Combina widgets para crear interfaces
- ✅ Comienza simple, complica progresivamente
- ✅ Practica con los ejercicios

**Próximo paso:** Una vez domines los widgets básicos, podrás aprender layouts avanzados, navegación y estado management.

---

## 📚 Conceptos Relacionados

**Temas que expanden esto:**
- [02_STATEFUL_STATELESS_LIFECYCLE.md](02_STATEFUL_STATELESS_LIFECYCLE.md) - Ciclo de vida profundo
- [03_ADVANCED_BUILDERS_STREAMS_FUTURE.md](03_ADVANCED_BUILDERS_STREAMS_FUTURE.md) - Widgets avanzados
- [06_SCAFFOLD_NAVEGACION.md](06_SCAFFOLD_NAVEGACION.md) - Layouts complejos
- [09_RESPONSIVE_DESIGN.md](09_RESPONSIVE_DESIGN.md) - Diseño adaptativo

**Ejercicios:**
- [EJERCICIOS_01_FUNDAMENTOS_WIDGETS.md](EJERCICIOS_01_FUNDAMENTOS_WIDGETS.md) - Practica aquí

**Recursos externos:**
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design Guidelines](https://material.io/design/guidelines)
- [Official Flutter Samples](https://github.com/flutter/samples)
