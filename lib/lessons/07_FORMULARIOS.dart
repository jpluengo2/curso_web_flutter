import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para InputFormatters

class Lab07Formularios extends StatelessWidget {
  const Lab07Formularios({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Laboratorio 07: Formularios Avanzados",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),

        // --- 1. TIPOS DE INPUT ---
        _buildSectionHeader("1. Variaciones de TextField"),
        _buildExampleCard(
          "Decoraciones, Iconos y Bordes",
          const Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Usuario", 
                  hintText: "ej. juan_perez",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()
                )
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña (Oculta)", 
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility_off),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  border: UnderlineInputBorder()
                )
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Teléfono (Teclado numérico)", 
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- 2. MANEJO DE FOCO (NUEVO) ---
        _buildSectionHeader("2. Control del Foco (FocusNode)"),
        const Text("Pulsa 'Enter' o 'Siguiente' en el teclado para saltar de campo."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Flujo de entrada continuo",
          const FocusNodeDemo(),
        ),

        const SizedBox(height: 30),

        // --- 3. FORMULARIO COMPLETO (MEJORADO) ---
        _buildSectionHeader("3. Validación y Envío Asíncrono"),
        const Text("Incluye Dropdown, Checkbox y estado de carga."),
        const SizedBox(height: 10),
        _buildExampleCard(
          "Registro de Usuario Completo",
          const AdvancedFormDemo(),
        ),

        const SizedBox(height: 30),

        // --- 4. SELECCIONES ---
        _buildSectionHeader("4. Widgets de Selección"),
        _buildExampleCard(
          "Interactivos: Switch, Radio, Slider",
          const SelectionWidgetsDemo(),
        ),

        const SizedBox(height: 30),

        // --- 5. FECHA Y HORA ---
        _buildSectionHeader("5. Selectores (Pickers)"),
        _buildExampleCard(
          "Date & Time Picker",
          const PickersDemo(),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Padding(padding: const EdgeInsets.all(15), child: content),
        ],
      ),
    );
  }
}

// --- DEMOS INTERACTIVOS ---

// 1. FOCUS NODE DEMO (NUEVO)
class FocusNodeDemo extends StatefulWidget {
  const FocusNodeDemo({super.key});
  @override
  State<FocusNodeDemo> createState() => _FocusNodeDemoState();
}

class _FocusNodeDemoState extends State<FocusNodeDemo> {
  late FocusNode _nombreFocus;
  late FocusNode _apellidoFocus;
  late FocusNode _edadFocus;

  @override
  void initState() {
    super.initState();
    _nombreFocus = FocusNode();
    _apellidoFocus = FocusNode();
    _edadFocus = FocusNode();
  }

  @override
  void dispose() {
    _nombreFocus.dispose();
    _apellidoFocus.dispose();
    _edadFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: _nombreFocus,
          decoration: const InputDecoration(labelText: "Nombre (Intro para saltar)", border: OutlineInputBorder()),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_apellidoFocus),
        ),
        const SizedBox(height: 10),
        TextField(
          focusNode: _apellidoFocus,
          decoration: const InputDecoration(labelText: "Apellido (Intro para saltar)", border: OutlineInputBorder()),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_edadFocus),
        ),
        const SizedBox(height: 10),
        TextField(
          focusNode: _edadFocus,
          decoration: const InputDecoration(labelText: "Edad (Fin)", border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

// 2. FORMULARIO AVANZADO (MEJORADO)
class AdvancedFormDemo extends StatefulWidget {
  const AdvancedFormDemo({super.key});
  @override
  State<AdvancedFormDemo> createState() => _AdvancedFormDemoState();
}

class _AdvancedFormDemoState extends State<AdvancedFormDemo> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _selectedRole;
  final TextEditingController _passCtrl = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes aceptar los términos"), backgroundColor: Colors.red));
        return;
      }

      setState(() => _isLoading = true);
      
      // Simular petición de red
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Registro completado!"), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email con validación
          TextFormField(
            decoration: const InputDecoration(labelText: "Email", icon: Icon(Icons.email), isDense: true),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || !value.contains("@")) return "Email inválido";
              return null;
            },
          ),
          const SizedBox(height: 10),
          
          // DropdownButtonFormField (NUEVO)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Rol de Usuario", icon: Icon(Icons.badge), isDense: true),
            value: _selectedRole,
            items: const [
              DropdownMenuItem(value: "Admin", child: Text("Administrador")),
              DropdownMenuItem(value: "User", child: Text("Usuario")),
              DropdownMenuItem(value: "Guest", child: Text("Invitado")),
            ],
            onChanged: (v) => setState(() => _selectedRole = v),
            validator: (v) => v == null ? "Selecciona un rol" : null,
          ),
          const SizedBox(height: 10),

          // Password
          TextFormField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Contraseña", icon: Icon(Icons.lock), isDense: true),
            validator: (v) => (v != null && v.length < 6) ? "Mínimo 6 caracteres" : null,
          ),
          const SizedBox(height: 15),

          // Checkbox Terms
          CheckboxListTile(
            title: const Text("Acepto los términos y condiciones", style: TextStyle(fontSize: 12)),
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v!),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 10),
          
          // Botón de Envío con Loading
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Registrarse"),
            ),
          )
        ],
      ),
    );
  }
}

// 3. WIDGETS DE SELECCIÓN
class SelectionWidgetsDemo extends StatefulWidget {
  const SelectionWidgetsDemo({super.key});
  @override
  State<SelectionWidgetsDemo> createState() => _SelectionWidgetsDemoState();
}

class _SelectionWidgetsDemoState extends State<SelectionWidgetsDemo> {
  bool _notifications = true;
  int _radioVal = 1;
  double _slider = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Recibir notificaciones"),
          subtitle: const Text("Push y Email"),
          value: _notifications,
          onChanged: (v) => setState(() => _notifications = v),
          secondary: const Icon(Icons.notifications_active),
        ),
        const Divider(),
        const Text("Preferencia de contacto:"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(value: 1, groupValue: _radioVal, onChanged: (v) => setState(() => _radioVal = v!)),
            const Text("Email"),
            const SizedBox(width: 20),
            Radio(value: 2, groupValue: _radioVal, onChanged: (v) => setState(() => _radioVal = v!)),
            const Text("SMS"),
          ],
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Icon(Icons.volume_down),
              Expanded(
                child: Slider(
                  value: _slider,
                  min: 0, max: 100,
                  divisions: 10,
                  label: _slider.round().toString(),
                  onChanged: (v) => setState(() => _slider = v),
                ),
              ),
              const Icon(Icons.volume_up),
            ],
          ),
        )
      ],
    );
  }
}

// 4. PICKERS
class PickersDemo extends StatefulWidget {
  const PickersDemo({super.key});
  @override
  State<PickersDemo> createState() => _PickersDemoState();
}

class _PickersDemoState extends State<PickersDemo> {
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Date Picker
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(_date == null ? "Fecha" : "${_date!.day}/${_date!.month}"),
          onPressed: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2030));
            if (d != null) setState(() => _date = d);
          },
        ),
        // Time Picker
        OutlinedButton.icon(
          icon: const Icon(Icons.access_time),
          label: Text(_time == null ? "Hora" : _time!.format(context)),
          onPressed: () async {
            final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (t != null) setState(() => _time = t);
          },
        ),
      ],
    );
  }
}