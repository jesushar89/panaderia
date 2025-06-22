import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  final List<String> _opcionesSexo = ['Masculino', 'Femenino', 'Otro'];
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nueva tarjeta de formulario: más plana, cuadrada, ligera
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(_nombresController, 'Nombres'),
                        const SizedBox(height: 18),
                        _buildTextField(_apellidosController, 'Apellidos'),
                        const SizedBox(height: 18),
                        _buildTextField(_emailController, 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 18),
                        _buildPasswordField(),
                        const SizedBox(height: 18),
                        _buildTextField(_edadController, 'Edad',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 18),
                        _buildDatePicker(),
                        const SizedBox(height: 18),
                        _buildDropdownSexo(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _guardarEnFirestore,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.button,
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: AppColors.button, width: 1.4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta?',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppColors.secondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.accent,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.highlight),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor completa este campo';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: const TextStyle(
            color: AppColors.secondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.accent,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.highlight),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _seleccionarFecha,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            labelStyle: const TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: AppColors.accent,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.highlight),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          controller: TextEditingController(
            text: _fechaNacimiento != null
                ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSexo() {
    return DropdownButtonFormField<String>(
      value: _sexoSeleccionado,
      items: _opcionesSexo.map((sexo) {
        return DropdownMenuItem(
          value: sexo,
          child: Text(sexo),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _sexoSeleccionado = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Sexo',
        labelStyle: const TextStyle(
            color: AppColors.secondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.accent,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.highlight),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _guardarEnFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // 1. Crea el usuario en Firebase Auth (genera UID automático)
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Guarda los datos en Firestore usando el UID como ID del documento
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid) // ¡UID automático aquí!
          .set({
        'nombres': _nombresController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'email': _emailController.text.trim(),
        'edad': _edadController.text.trim(),
        'fechaNacimiento': _fechaNacimiento,
        'sexo': _sexoSeleccionado,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: ${e.toString()}')),
      );
    }
  }
}
