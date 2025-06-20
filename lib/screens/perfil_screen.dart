import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Nuevo avatar con borde y sombra suave
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/images/usuario.png'),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Andrea Ramírez',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'andrearamirez@email.com',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 28),
              // Botones de acción con diseño fresco
              _tileCard(context, 'Editar perfil', Icons.edit, AppColors.primary),
              _tileCard(context, 'Mis Direcciones', Icons.location_on, AppColors.secondary),
              _tileCard(context, 'Cerrar sesión', Icons.logout, Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileCard(BuildContext context, String titulo, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.32)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.09),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        leading: Icon(icon, color: color, size: 26),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: () {
          if (titulo == 'Editar perfil') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditarPerfilScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _nombreController = TextEditingController(text: 'Andrea Ramírez');
  final TextEditingController _apellidoController = TextEditingController(text: 'Ramírez');
  final TextEditingController _emailController = TextEditingController(text: 'andrearamirez@email.com');
  final TextEditingController _edadController = TextEditingController(text: '25');
  final TextEditingController _fechaNacimientoController = TextEditingController(text: '1997-01-01');
  final TextEditingController _sexoController = TextEditingController(text: 'Femenino');
  final TextEditingController _passwordController = TextEditingController(text: 'password');

  void _guardarCambios() async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc('user-id');

    try {
      await userDocRef.update({
        'nombres': _nombreController.text,
        'apellidos': _apellidoController.text,
        'correo': _emailController.text,
        'edad': _edadController.text,
        'fechaNacimiento': _fechaNacimientoController.text,
        'sexo': _sexoController.text,
        'password': _passwordController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/usuario.png'),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(_nombreController, 'Nombres'),
              const SizedBox(height: 13),
              _buildInputField(_apellidoController, 'Apellidos'),
              const SizedBox(height: 13),
              _buildInputField(_emailController, 'Correo electrónico'),
              const SizedBox(height: 13),
              _buildInputField(_edadController, 'Edad'),
              const SizedBox(height: 13),
              _buildInputField(_fechaNacimientoController, 'Fecha de Nacimiento'),
              const SizedBox(height: 13),
              _buildInputField(_sexoController, 'Sexo'),
              const SizedBox(height: 13),
              _buildInputField(_passwordController, 'Nueva Contraseña', obscureText: true),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _guardarCambios,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.accent,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
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
}