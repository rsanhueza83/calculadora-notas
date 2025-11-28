import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculadoraNotasApp());
}

class CalculadoraNotasApp extends StatelessWidget {
  const CalculadoraNotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Notas Dinámica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CalculadoraNotasPage(),
    );
  }
}

// Formateador personalizado (Mismo de antes)
class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll('.', ',');
    int commaCount = ','.allMatches(newText).length;
    if (commaCount > 1) {
      return oldValue;
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CalculadoraNotasPage extends StatefulWidget {
  const CalculadoraNotasPage({super.key});

  @override
  State<CalculadoraNotasPage> createState() => _CalculadoraNotasPageState();
}

class _CalculadoraNotasPageState extends State<CalculadoraNotasPage> {
  final _formKey = GlobalKey<FormState>();

  // --- CAMBIO PRINCIPAL: Listas en lugar de variables sueltas ---
  int _cantidadNotas = 3; // Valor inicial
  final List<TextEditingController> _notasControllers = [];
  final List<TextEditingController> _porcentajesControllers = [];
  
  // Listas para manejar los errores visuales
  final List<bool> _notasErrors = [];
  final List<bool> _porcentajesErrors = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos con la cantidad por defecto (3)
    _actualizarCantidadControladores(3);
  }

  // Esta función gestiona la creación o eliminación de inputs dinámicamente
  void _actualizarCantidadControladores(int nuevaCantidad) {
    // Si aumentamos notas
    if (nuevaCantidad > _notasControllers.length) {
      for (int i = _notasControllers.length; i < nuevaCantidad; i++) {
        // Crear controladores
        final notaCtrl = TextEditingController();
        final porcCtrl = TextEditingController();
        
        // Agregar listeners con el índice capturado
        // Usamos una función auxiliar para capturar el índice 'i' correctamente
        notaCtrl.addListener(() => _validarNotaEnTiempoReal(i));
        porcCtrl.addListener(() => _validarPorcentajeEnTiempoReal(i));

        setState(() {
          _notasControllers.add(notaCtrl);
          _porcentajesControllers.add(porcCtrl);
          _notasErrors.add(false);
          _porcentajesErrors.add(false);
        });
      }
    } 
    // Si disminuimos notas
    else if (nuevaCantidad < _notasControllers.length) {
      for (int i = _notasControllers.length - 1; i >= nuevaCantidad; i--) {
        // Importante: Eliminar listeners y liberar memoria
        _notasControllers[i].dispose();
        _porcentajesControllers[i].dispose();
        
        setState(() {
          _notasControllers.removeAt(i);
          _porcentajesControllers.removeAt(i);
          _notasErrors.removeAt(i);
          _porcentajesErrors.removeAt(i);
        });
      }
    }
    
    setState(() {
      _cantidadNotas = nuevaCantidad;
    });
  }

  @override
  void dispose() {
    // Limpieza general al cerrar la app
    for (var controller in _notasControllers) {
      controller.dispose();
    }
    for (var controller in _porcentajesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- Validaciones Adaptadas a Índices ---

  void _mostrarErrorPopup(String mensaje, IconData icono) {
    // (Misma lógica de popup de error, sin cambios)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(icono, color: Colors.red, size: 40),
        title: Text(mensaje, style: const TextStyle(fontSize: 14, color: Colors.red), textAlign: TextAlign.center),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar"))],
      ),
    );
  }

  void _validarNotaEnTiempoReal(int index) {
    // Obtenemos el controlador de la lista usando el index
    final controller = _notasControllers[index];
    
    if (controller.text.isEmpty) {
      setState(() => _notasErrors[index] = false);
      return;
    }

    final nota = double.tryParse(controller.text.replaceAll(',', '.'));
    bool hasError = false;
    
    if (nota == null || nota < 1.0 || nota > 7.0) {
      hasError = true;
    }

    setState(() => _notasErrors[index] = hasError);
  }

  void _validarPorcentajeEnTiempoReal(int index) {
    final controller = _porcentajesControllers[index];
    
    if (controller.text.isEmpty) {
      setState(() => _porcentajesErrors[index] = false);
      return;
    }

    final porcentaje = double.tryParse(controller.text.replaceAll(',', '.'));
    bool hasError = false;
    
    if (porcentaje == null || porcentaje < 0 || porcentaje > 100) {
      hasError = true;
    }

    setState(() => _porcentajesErrors[index] = hasError);
  }

  String? _validarNota(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    final nota = double.tryParse(value.replaceAll(',', '.'));
    if (nota == null) return 'Inválido';
    if (nota < 1.0 || nota > 7.0) return '1.0 - 7.0';
    return null;
  }

  String? _validarPorcentaje(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    final p = double.tryParse(value.replaceAll(',', '.'));
    if (p == null) return 'Inválido';
    if (p < 0 || p > 100) return '0 - 100';
    return null;
  }

  void _calcularPromedio() {
    if (_formKey.currentState!.validate()) {
      double sumaPorcentajes = 0;
      double sumaPonderada = 0;

      // Iteramos dinámicamente sobre la lista actual
      for (int i = 0; i < _cantidadNotas; i++) {
        final nota = double.parse(_notasControllers[i].text.replaceAll(',', '.'));
        final porcentaje = double.parse(_porcentajesControllers[i].text.replaceAll(',', '.'));
        
        sumaPorcentajes += porcentaje;
        sumaPonderada += (nota * porcentaje / 100);
      }

      if ((sumaPorcentajes - 100).abs() > 0.01) {
         showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("⚠️ Error en Porcentajes"),
            content: Text("La suma de los porcentajes es ${sumaPorcentajes.toStringAsFixed(1)}%. Debe ser exactamente 100%."),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Corregir"))],
          ),
        );
        return;
      }

      _mostrarResultadoPopup(sumaPonderada);
    }
  }

  void _mostrarResultadoPopup(double promedio) {
    final bool aprobado = promedio >= 5.5; // Umbral de aprobación (modificable)

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: aprobado 
                  ? [Colors.green.shade50, Colors.green.shade100]
                  : [Colors.red.shade50, Colors.red.shade100],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  aprobado ? Icons.check_circle : Icons.warning,
                  size: 64,
                  color: aprobado ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  promedio.toStringAsFixed(2).replaceAll('.', ','),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: aprobado ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const Text("Promedio Final"),
                const SizedBox(height: 20),
                Text(
                  aprobado ? '¡Aprobado!' : 'Reprobado / Examen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: aprobado ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _limpiar() {
    for (var ctrl in _notasControllers) ctrl.clear();
    for (var ctrl in _porcentajesControllers) ctrl.clear();
    setState(() {
      for (int i=0; i<_cantidadNotas; i++) {
        _notasErrors[i] = false;
        _porcentajesErrors[i] = false;
      }
    });
  }

  // --- Widget para construir inputs en bucle ---
  Widget _buildNotaInput(int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Círculo con el número de nota
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            // Input Nota
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _notasControllers[index],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  DecimalTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Nota',
                  isDense: true,
                  errorText: _notasErrors[index] ? 'Inválido' : null,
                  border: const OutlineInputBorder(),
                ),
                validator: _validarNota,
              ),
            ),
            const SizedBox(width: 10),
            // Input Porcentaje
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _porcentajesControllers[index],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  DecimalTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: '%',
                  suffixText: '%',
                  isDense: true,
                  errorText: _porcentajesErrors[index] ? 'Error' : null,
                  border: const OutlineInputBorder(),
                ),
                validator: _validarPorcentaje,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora Dinámica'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SELECCION DE CANTIDAD DE NOTAS ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cantidad de Notas:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: _cantidadNotas,
                      underline: Container(), // Quitar la línea fea de abajo
                      icon: const Icon(Icons.layers, color: Colors.blue),
                      items: List.generate(9, (index) => index + 2).map((int number) {
                        // Genera lista de 2 a 10
                        return DropdownMenuItem<int>(
                          value: number,
                          child: Text('$number notas', style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          _actualizarCantidadControladores(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // --- GENERACIÓN DINÁMICA DE INPUTS ---
              // Usamos el operador spread (...) y List.generate
              ...List.generate(_cantidadNotas, (index) => _buildNotaInput(index)),
              
              const SizedBox(height: 20),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calcularPromedio,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calcular Promedio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _limpiar,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}