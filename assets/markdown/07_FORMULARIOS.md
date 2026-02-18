# Formularios en Flutter - Guía Completa

## 📚 Tabla de Contenidos
1. [Introducción](#introducción)
2. [TextField - Campo de texto básico](#textfield---campo-de-texto-básico)
3. [Form y FormField](#form-y-formfield)
4. [TextEditingController](#texteditingcontroller)
5. [Validadores](#validadores)
6. [Tipos de entrada](#tipos-de-entrada)
7. [Widgets de selección](#widgets-de-selección)
8. [Date y Time Picker](#date-y-time-picker)
9. [Formulario completo](#formulario-completo)
10. [Ejemplos prácticos](#ejemplos-prácticos)
11. [Mejores prácticas](#mejores-prácticas)

---

## Introducción

Los formularios son elementos esenciales en cualquier aplicación. Necesitamos:
- **Recopilar datos** del usuario
- **Validar entrada** antes de enviar
- **Mostrar errores** de forma clara
- **Mantener estado** de los campos

### Componentes principales
- **TextField**: Campo de texto individual
- **Form**: Contenedor para múltiples campos
- **FormField**: Campo dentro de un formulario
- **Validators**: Funciones de validación

---

## TextField - Campo de Texto Básico

### TextField simple

```dart
import 'package:flutter/material.dart';

class SimpleTextFieldExample extends StatefulWidget {
  @override
  State<SimpleTextFieldExample> createState() => _SimpleTextFieldExampleState();
}

class _SimpleTextFieldExampleState extends State<SimpleTextFieldExample> {
  String inputText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TextField Simple')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // TextField básico
            TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ingresa tu nombre',
              ),
            ),
            SizedBox(height: 20),
            Text('Texto ingresado: $inputText'),
          ],
        ),
      ),
    );
  }
}
```

### TextField con decoración completa

```dart
class DecoratedTextFieldExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        // Estilos de texto
        style: TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.left,
        maxLength: 50,
        
        // Decoración
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          labelStyle: TextStyle(color: Colors.blue),
          hintText: 'ejemplo@email.com',
          hintStyle: TextStyle(color: Colors.grey),
          
          // Icono
          prefixIcon: Icon(Icons.email),
          suffixIcon: Icon(Icons.check),
          
          // Bordes
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          
          // Colores
          filled: true,
          fillColor: Colors.grey[100],
          
          // Padding
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          
          // Errores
          errorText: null,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        
        // Comportamiento
        obscureText: false,
        enableSuggestions: true,
        autocorrect: true,
      ),
    );
  }
}
```

### Estilos predefinidos

```dart
class TextFieldStylesExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Estilo: Outline
          TextField(
            decoration: InputDecoration(
              labelText: 'Outline',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Estilo: Underline
          TextField(
            decoration: InputDecoration(
              labelText: 'Underline',
              border: UnderlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Estilo: Filled
          TextField(
            decoration: InputDecoration(
              labelText: 'Filled',
              filled: true,
              fillColor: Colors.grey[200],
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 16),

          // Estilo: Custom
          TextField(
            decoration: InputDecoration(
              labelText: 'Custom',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.blue[50],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Form y FormField

### Form básico

```dart
class BasicFormExample extends StatefulWidget {
  @override
  State<BasicFormExample> createState() => _BasicFormExampleState();
}

class _BasicFormExampleState extends State<BasicFormExample> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  String? _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulario Básico')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Campo: Nombre
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nombre = value;
                },
              ),
              SizedBox(height: 16),

              // Campo: Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              SizedBox(height: 24),

              // Botón enviar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    print('Nombre: $_nombre, Email: $_email');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Formulario válido')),
                    );
                  }
                },
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Custom FormField

```dart
class CustomFormFieldExample extends StatefulWidget {
  @override
  State<CustomFormFieldExample> createState() => _CustomFormFieldExampleState();
}

class _CustomFormFieldExampleState extends State<CustomFormFieldExample> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // FormField personalizado: Contador
            FormField<int>(
              initialValue: 0,
              validator: (value) {
                if (value == null || value <= 0) {
                  return 'Selecciona una cantidad mayor a 0';
                }
                return null;
              },
              builder: (FormFieldState<int> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            state.didChange((state.value ?? 0) - 1);
                          },
                        ),
                        Text('Cantidad: ${state.value ?? 0}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            state.didChange((state.value ?? 0) + 1);
                          },
                        ),
                      ],
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText ?? '',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print('Formulario válido');
                }
              },
              child: Text('Validar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## TextEditingController

### Usar TextEditingController

```dart
class TextEditingControllerExample extends StatefulWidget {
  @override
  State<TextEditingControllerExample> createState() =>
    _TextEditingControllerExampleState();
}

class _TextEditingControllerExampleState
    extends State<TextEditingControllerExample> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios
    _controller.addListener(() {
      print('Texto: ${_controller.text}');
    });
  }

  @override
  void dispose() {
    // IMPORTANTE: Siempre liberar recursos
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TextEditingController')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // TextField con controller
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                      },
                    ),
              ),
            ),
            SizedBox(height: 16),

            // Mostrar texto del controller
            Text('Texto actual: ${_controller.text}'),
            SizedBox(height: 16),

            // Botones de control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Establecer valor
                    _controller.text = 'Nombre predefinido';
                  },
                  child: Text('Establecer valor'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Limpiar
                    _controller.clear();
                  },
                  child: Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Comparación: onChanged vs TextEditingController

```dart
class ComparisonControllerExample extends StatefulWidget {
  @override
  State<ComparisonControllerExample> createState() =>
    _ComparisonControllerExampleState();
}

class _ComparisonControllerExampleState
    extends State<ComparisonControllerExample> {
  final TextEditingController _controller = TextEditingController();
  String _onChangedValue = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Con controller: Acceso programático
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Con Controller'),
          ),
          SizedBox(height: 8),
          Text('Controller: ${_controller.text}'),
          SizedBox(height: 16),

          // Con onChanged: Solo reactividad
          TextField(
            onChanged: (value) {
              setState(() => _onChangedValue = value);
            },
            decoration: InputDecoration(labelText: 'Con onChanged'),
          ),
          SizedBox(height: 8),
          Text('onChanged: $_onChangedValue'),
          SizedBox(height: 16),

          // Diferencias
          Text(
            'Controller: Acceso y modificación programática\n'
            'onChanged: Solo reactividad a cambios',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
```

---

## Validadores

### Validadores comunes

```dart
class ValidatorsExample extends StatefulWidget {
  @override
  State<ValidatorsExample> createState() => _ValidatorsExampleState();
}

class _ValidatorsExampleState extends State<ValidatorsExample> {
  final _formKey = GlobalKey<FormState>();

  // Validador: Email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un email';
    }
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  // Validador: Contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener una mayúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener un número';
    }
    return null;
  }

  // Validador: Teléfono
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un teléfono';
    }
    if (!value.contains(RegExp(r'^\+?[0-9]{7,15}$'))) {
      return 'Teléfono inválido';
    }
    return null;
  }

  // Validador: URL
  String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una URL';
    }
    try {
      Uri.parse(value);
      if (!value.startsWith('http')) {
        return 'URL debe empezar con http o https';
      }
      return null;
    } catch (e) {
      return 'URL inválida';
    }
  }

  // Validador: Número
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un número';
    }
    if (int.tryParse(value) == null) {
      return 'Debe ser un número válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Validadores')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: validateEmail,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: validatePhone,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
                validator: validateUrl,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
                validator: validateNumber,
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Todos los campos son válidos');
                  }
                },
                child: Text('Validar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Clase reutilizable de validadores

```dart
class Validators {
  // Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requerido';
    const pattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) return 'Email inválido';
    return null;
  }

  // Contraseña fuerte
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Necesita mayúscula';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Necesita minúscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Necesita número';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Necesita carácter especial';
    }
    return null;
  }

  // Campo requerido
  static String? required(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.isEmpty) return '$fieldName requerido';
    return null;
  }

  // Longitud mínima
  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    if (value.length < min) return 'Mínimo $min caracteres';
    return null;
  }

  // Longitud máxima
  static String? maxLength(String? value, int max) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    if (value.length > max) return 'Máximo $max caracteres';
    return null;
  }

  // Solo números
  static String? numbersOnly(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Solo números';
    return null;
  }

  // Solo letras
  static String? lettersOnly(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Solo letras';
    return null;
  }

  // Teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Teléfono requerido';
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
      return 'Teléfono inválido';
    }
    return null;
  }

  // Valor mínimo
  static String? minValue(String? value, num min) {
    if (value == null || value.isEmpty) return 'Requerido';
    final num? numValue = num.tryParse(value);
    if (numValue == null) return 'Debe ser un número';
    if (numValue < min) return 'Mínimo $min';
    return null;
  }

  // Valor máximo
  static String? maxValue(String? value, num max) {
    if (value == null || value.isEmpty) return 'Requerido';
    final num? numValue = num.tryParse(value);
    if (numValue == null) return 'Debe ser un número';
    if (numValue > max) return 'Máximo $max';
    return null;
  }
}

// Uso
TextFormField(
  validator: (value) => Validators.email(value),
)

TextFormField(
  validator: (value) => Validators.minLength(value, 6),
)
```

---

## Tipos de Entrada

### TextField con diferentes keyboard types

```dart
class InputTypesExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tipos de Entrada')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Texto normal
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Texto normal',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Email
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Teléfono
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Número
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número entero',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Número decimal
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Número decimal',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // URL
            TextField(
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Multiline (Textarea)
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción (multiline)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### TextField con formato de entrada

```dart
import 'package:flutter/services.dart';

class FormattedInputExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Solo números
          TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Solo números',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Longitud máxima
          TextField(
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            decoration: InputDecoration(
              labelText: 'Máximo 10 caracteres',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Formato personalizado: Teléfono (###-###-####)
          TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
              PhoneNumberFormatter(),
            ],
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Teléfono (###-###-####)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Mayúsculas automáticas
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Capitalizar oración',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // Todo mayúsculas
          TextField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Todo mayúsculas',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

// Formateador personalizado: Teléfono
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    if (text.length <= 3) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
```

### Contraseña visible/oculta

```dart
class PasswordFieldExample extends StatefulWidget {
  @override
  State<PasswordFieldExample> createState() => _PasswordFieldExampleState();
}

class _PasswordFieldExampleState extends State<PasswordFieldExample> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }
}
```

---

## Widgets de Selección

### Checkbox

```dart
class CheckboxExample extends StatefulWidget {
  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool _isChecked = false;
  List<bool> _hobbies = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkbox')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox simple
            CheckboxListTile(
              title: Text('Acepto términos y condiciones'),
              value: _isChecked,
              onChanged: (value) {
                setState(() => _isChecked = value ?? false);
              },
            ),
            SizedBox(height: 24),

            // Múltiples checkboxes
            Text('Hobbies:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: Text('Leer'),
              value: _hobbies[0],
              onChanged: (value) {
                setState(() => _hobbies[0] = value ?? false);
              },
            ),
            CheckboxListTile(
              title: Text('Deporte'),
              value: _hobbies[1],
              onChanged: (value) {
                setState(() => _hobbies[1] = value ?? false);
              },
            ),
            CheckboxListTile(
              title: Text('Música'),
              value: _hobbies[2],
              onChanged: (value) {
                setState(() => _hobbies[2] = value ?? false);
              },
            ),
            CheckboxListTile(
              title: Text('Videojuegos'),
              value: _hobbies[3],
              onChanged: (value) {
                setState(() => _hobbies[3] = value ?? false);
              },
            ),
            SizedBox(height: 24),

            Text('Seleccionados: ${_hobbies.where((h) => h).length}'),
          ],
        ),
      ),
    );
  }
}
```

### Radio

```dart
class RadioExample extends StatefulWidget {
  @override
  State<RadioExample> createState() => _RadioExampleState();
}

class _RadioExampleState extends State<RadioExample> {
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Radio Button')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona tu nivel:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Radio buttons con RadioListTile
            RadioListTile<String>(
              title: Text('Principiante'),
              value: 'beginner',
              groupValue: _selectedLevel,
              onChanged: (value) {
                setState(() => _selectedLevel = value);
              },
            ),
            RadioListTile<String>(
              title: Text('Intermedio'),
              value: 'intermediate',
              groupValue: _selectedLevel,
              onChanged: (value) {
                setState(() => _selectedLevel = value);
              },
            ),
            RadioListTile<String>(
              title: Text('Avanzado'),
              value: 'advanced',
              groupValue: _selectedLevel,
              onChanged: (value) {
                setState(() => _selectedLevel = value);
              },
            ),

            SizedBox(height: 24),
            Text('Seleccionado: $_selectedLevel'),
          ],
        ),
      ),
    );
  }
}
```

### Switch

```dart
class SwitchExample extends StatefulWidget {
  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool _isDarkMode = false;
  bool _enableNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Switch')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Switch con SwitchListTile
            SwitchListTile(
              title: Text('Modo oscuro'),
              subtitle: Text('Activar tema oscuro'),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() => _isDarkMode = value);
              },
            ),
            Divider(),
            SwitchListTile(
              title: Text('Notificaciones'),
              subtitle: Text('Recibir notificaciones'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() => _enableNotifications = value);
              },
            ),
            SizedBox(height: 24),

            // Switch manual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ubicación'),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### DropdownButton

```dart
class DropdownExample extends StatefulWidget {
  @override
  State<DropdownExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String? _selectedCountry;
  List<String> countries = ['España', 'México', 'Argentina', 'Colombia'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dropdown')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // DropdownButton simple
            DropdownButton<String>(
              hint: Text('Selecciona un país'),
              value: _selectedCountry,
              isExpanded: true,
              items: countries
                .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
                .toList(),
              onChanged: (value) {
                setState(() => _selectedCountry = value);
              },
            ),
            SizedBox(height: 24),

            // DropdownButton con formato personalizado
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                hint: Text('Selecciona un país'),
                value: _selectedCountry,
                isExpanded: true,
                underline: SizedBox(), // Remover línea predefinida
                items: countries
                  .map((country) => DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  ))
                  .toList(),
                onChanged: (value) {
                  setState(() => _selectedCountry = value);
                },
              ),
            ),
            SizedBox(height: 24),

            Text('Seleccionado: $_selectedCountry'),
          ],
        ),
      ),
    );
  }
}
```

### Segmented Button

```dart
class SegmentedButtonExample extends StatefulWidget {
  @override
  State<SegmentedButtonExample> createState() => _SegmentedButtonExampleState();
}

class _SegmentedButtonExampleState extends State<SegmentedButtonExample> {
  String _selectedSize = 'M';
  Set<String> _selectedToppings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Segmented Button')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tamaño (selección única):'),
            SizedBox(height: 8),
            SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'S',
                  label: Text('Pequeño'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment<String>(
                  value: 'M',
                  label: Text('Mediano'),
                ),
                ButtonSegment<String>(
                  value: 'L',
                  label: Text('Grande'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: <String>{_selectedSize},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedSize = newSelection.first);
              },
            ),
            SizedBox(height: 24),

            Text('Toppings (selección múltiple):'),
            SizedBox(height: 8),
            SegmentedButton<String>(
              multiSelectionEnabled: true,
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'queso',
                  label: Text('Queso'),
                ),
                ButtonSegment<String>(
                  value: 'pepperoni',
                  label: Text('Pepperoni'),
                ),
                ButtonSegment<String>(
                  value: 'vegetales',
                  label: Text('Vegetales'),
                ),
              ],
              selected: _selectedToppings,
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedToppings = newSelection);
              },
            ),
            SizedBox(height: 24),

            Text('Seleccionado: $_selectedSize'),
            Text('Toppings: ${_selectedToppings.join(", ")}'),
          ],
        ),
      ),
    );
  }
}
```

### Slider

```dart
class SliderExample extends StatefulWidget {
  @override
  State<SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<SliderExample> {
  double _volume = 50;
  double _brightness = 50;
  RangeValues _priceRange = RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Slider')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Slider simple
            Text('Volumen: ${_volume.toStringAsFixed(0)}%'),
            Slider(
              value: _volume,
              min: 0,
              max: 100,
              divisions: 10,
              label: _volume.toStringAsFixed(0),
              onChanged: (value) {
                setState(() => _volume = value);
              },
            ),
            SizedBox(height: 24),

            // Slider con rango
            Text('Brillo: ${_brightness.toStringAsFixed(0)}%'),
            Slider(
              value: _brightness,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() => _brightness = value);
              },
            ),
            SizedBox(height: 24),

            // Range Slider
            Text('Rango de precio: \$${_priceRange.start.toStringAsFixed(0)} - \$${_priceRange.end.toStringAsFixed(0)}'),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 500,
              divisions: 50,
              labels: RangeLabels(
                _priceRange.start.toStringAsFixed(0),
                _priceRange.end.toStringAsFixed(0),
              ),
              onChanged: (RangeValues newValues) {
                setState(() => _priceRange = newValues);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Date y Time Picker

### DatePicker

```dart
class DatePickerExample extends StatefulWidget {
  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Date Picker')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Mostrar fecha seleccionada
            Text(
              _selectedDate == null
                ? 'No hay fecha seleccionada'
                : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),

            // Botón para abrir picker
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Seleccionar fecha'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### TimePicker

```dart
class TimePickerExample extends StatefulWidget {
  @override
  State<TimePickerExample> createState() => _TimePickerExampleState();
}

class _TimePickerExampleState extends State<TimePickerExample> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Time Picker')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _selectedTime == null
                ? 'No hay hora seleccionada'
                : 'Hora: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Seleccionar hora'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Date y Time combinados

```dart
class DateTimePickerExample extends StatefulWidget {
  @override
  State<DateTimePickerExample> createState() => _DateTimePickerExampleState();
}

class _DateTimePickerExampleState extends State<DateTimePickerExample> {
  DateTime? _appointmentDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _appointmentDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _appointmentDateTime ?? DateTime.now(),
      ),
    );

    if (pickedTime == null) return;

    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() => _appointmentDateTime = combined);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Date & Time Picker')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _appointmentDateTime == null
                ? 'No hay cita seleccionada'
                : 'Cita: ${_appointmentDateTime!.day}/${_appointmentDateTime!.month}/${_appointmentDateTime!.year} '
                    '${_appointmentDateTime!.hour}:${_appointmentDateTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => _selectDateTime(context),
              child: Text('Seleccionar cita'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Formulario Completo

### Formulario de registro

```dart
class RegistrationFormExample extends StatefulWidget {
  @override
  State<RegistrationFormExample> createState() =>
    _RegistrationFormExampleState();
}

class _RegistrationFormExampleState extends State<RegistrationFormExample> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _gender;
  DateTime? _birthDate;
  bool _termsAccepted = false;
  List<bool> _interests = [false, false, false, false];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Género
              Text('Género:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                hint: Text('Selecciona tu género'),
                value: _gender,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'male', child: Text('Hombre')),
                  DropdownMenuItem(value: 'female', child: Text('Mujer')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                ]
                  .map((item) => item)
                  .toList(),
                onChanged: (value) {
                  setState(() => _gender = value);
                },
              ),
              SizedBox(height: 16),

              // Fecha de nacimiento
              Text('Fecha de nacimiento:',
                style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDate == null
                        ? 'Selecciona una fecha'
                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _birthDate ?? DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _birthDate = picked);
                      }
                    },
                    child: Text('Seleccionar'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Intereses
              Text('Intereses:', style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Deportes'),
                value: _interests[0],
                onChanged: (value) {
                  setState(() => _interests[0] = value ?? false);
                },
              ),
              CheckboxListTile(
                title: Text('Música'),
                value: _interests[1],
                onChanged: (value) {
                  setState(() => _interests[1] = value ?? false);
                },
              ),
              CheckboxListTile(
                title: Text('Películas'),
                value: _interests[2],
                onChanged: (value) {
                  setState(() => _interests[2] = value ?? false);
                },
              ),
              CheckboxListTile(
                title: Text('Viajes'),
                value: _interests[3],
                onChanged: (value) {
                  setState(() => _interests[3] = value ?? false);
                },
              ),
              SizedBox(height: 16),

              // Términos y condiciones
              CheckboxListTile(
                title: Text('Acepto términos y condiciones'),
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() => _termsAccepted = value ?? false);
                },
              ),
              SizedBox(height: 24),

              // Botón enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _termsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registro exitoso')),
                      );
                    } else if (!_termsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Debes aceptar los términos y condiciones',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Registrarse'),
                ),
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

## Ejemplos Prácticos

### Formulario de login

```dart
class LoginFormExample extends StatefulWidget {
  @override
  State<LoginFormExample> createState() => _LoginFormExampleState();
}

class _LoginFormExampleState extends State<LoginFormExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(Icons.lock, size: 64, color: Colors.blue),
                SizedBox(height: 24),

                // Título
                Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Inicia sesión en tu cuenta',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 32),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Contraseña requerida';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Recuérdame
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    Text('Recuérdame'),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text('¿Olvidó su contraseña?'),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Botón login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('Login correcto');
                      }
                    },
                    child: Text('Iniciar sesión'),
                  ),
                ),
                SizedBox(height: 16),

                // Crear cuenta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta? '),
                    TextButton(
                      onPressed: () {},
                      child: Text('Regístrate aquí'),
                    ),
                  ],
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

### Formulario de contacto

```dart
class ContactFormExample extends StatefulWidget {
  @override
  State<ContactFormExample> createState() => _ContactFormExampleState();
}

class _ContactFormExampleState extends State<ContactFormExample> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contáctanos')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                hint: Text('Selecciona una categoría'),
                value: _selectedCategory,
                items: [
                  'Soporte',
                  'Ventas',
                  'Feedback',
                  'Otro',
                ]
                  .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                  .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Asunto',
                  prefixIcon: Icon(Icons.subject),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Asunto requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Mensaje',
                  border: OutlineInputBorder(),
                  hintText: 'Escribe tu mensaje aquí...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mensaje requerido';
                  }
                  if (value.length < 10) {
                    return 'Mínimo 10 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                    ? null
                    : () {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isSubmitting = true);
                        
                        // Simular envío
                        Future.delayed(Duration(seconds: 2), () {
                          setState(() => _isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Mensaje enviado')),
                          );
                          _nameController.clear();
                          _emailController.clear();
                          _subjectController.clear();
                          _messageController.clear();
                          setState(() => _selectedCategory = null);
                        });
                      }
                    },
                  child: _isSubmitting
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text('Enviar mensaje'),
                ),
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

## Mejores Prácticas

### 1. Siempre usar GlobalKey<FormState>

```dart
// ✅ Bien
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(...),
)

if (_formKey.currentState!.validate()) {
  _formKey.currentState!.save();
}

// ❌ Evitar
// No guardar el estado del formulario sin GlobalKey
```

### 2. Limpiar TextEditingController

```dart
// ✅ Bien
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // IMPORTANTE
    super.dispose();
  }
}

// ❌ Evitar
// Olvidar llamar dispose() causa memory leaks
```

### 3. Usar TextFormField en lugar de TextField dentro de Forms

```dart
// ✅ Bien
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(validator: (value) => ...),
    ],
  ),
)

// ❌ Evitar
Form(
  key: _formKey,
  child: Column(
    children: [
      TextField(), // No funciona bien con Form
    ],
  ),
)
```

### 4. Validar y guardar correctamente

```dart
// ✅ Bien
if (_formKey.currentState!.validate()) {
  _formKey.currentState!.save(); // Llamar save() primero
  // Ahora los valores están en onSaved()
}

// ❌ Evitar
if (_formKey.currentState!.validate()) {
  // Usar el valor sin llamar save()
}
```

### 5. Mostrar errores de forma clara

```dart
// ✅ Bien
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    errorText: _emailError, // Mostrar error específico
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email requerido';
    }
    if (!value.contains('@')) {
      return 'Debe contener @';
    }
    return null;
  },
)

// ❌ Evitar
TextFormField(
  validator: (_) => 'Error', // Mensaje genérico
)
```

### 6. Crear clase para validadores reutilizables

```dart
// ✅ Bien
class FormValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requerido';
    if (!value.contains('@')) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }
}

// Uso
TextFormField(validator: FormValidators.email)
```

### 7. Manejo de state durante carga

```dart
// ✅ Bien
bool _isLoading = false;

ElevatedButton(
  onPressed: _isLoading ? null : () async {
    setState(() => _isLoading = true);
    try {
      await _submitForm();
    } finally {
      setState(() => _isLoading = false);
    }
  },
  child: _isLoading
    ? CircularProgressIndicator()
    : Text('Enviar'),
)
```

### 8. Usar FocusNode para controlar el foco

```dart
// ✅ Bien
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  late FocusNode _nameFocus;
  late FocusNode _emailFocus;

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: _nameFocus,
          onSubmitted: (_) => _emailFocus.requestFocus(),
        ),
        TextField(
          focusNode: _emailFocus,
        ),
      ],
    );
  }
}
```

---

Conceptos Relacionados:
- 04_LISTVIEW_SCROLLVIEW
- 11_GESTURES_EVENTOS  
- 13_PERSISTENCIA_DATOS
- 14_CONSUMO_APIS
- 17_MANEJO_ERRORES

**Documento actualizado: Febrero 2026**
**Versión: 1.0**
**Para alumnos de Flutter - Nivel Intermedio**
