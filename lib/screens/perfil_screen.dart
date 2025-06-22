import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<Map<String, dynamic>> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (!doc.exists) throw Exception('Datos de usuario no encontrados');
    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data!;
          return _buildProfileContent(context, userData);
        },
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
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
            Text(
              '${userData['nombres']} ${userData['apellidos']}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              userData['email'],
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 28),
            _tileCard(context, 'Editar perfil', Icons.edit, AppColors.primary),
            _tileCard(context, 'Mis Direcciones', Icons.location_on,
                AppColors.secondary),
            _tileCard(context, 'Cerrar sesión', Icons.logout, Colors.redAccent,
                onTap: _signOut),
          ],
        ),
      ),
    );
  }

  Widget _tileCard(
      BuildContext context, String titulo, IconData icon, Color color,
      {VoidCallback? onTap}) {
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
        onTap: onTap ??
            () {
              if (titulo == 'Editar perfil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditarPerfilScreen(userData: {}), // Pasa los datos aquí
                  ),
                );
              }
            },
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditarPerfilScreen({super.key, required this.userData});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _edadController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _sexoController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.userData['nombres'] ?? '');
    _apellidoController =
        TextEditingController(text: widget.userData['apellidos'] ?? '');
    _emailController =
        TextEditingController(text: widget.userData['email'] ?? '');
    _edadController =
        TextEditingController(text: widget.userData['edad']?.toString() ?? '');
    _fechaNacimientoController = TextEditingController(
        text: widget.userData['fechaNacimiento'] is Timestamp
            ? _formatDate(widget.userData['fechaNacimiento'].toDate())
            : widget.userData['fechaNacimiento']?.toString() ?? '');
    _sexoController =
        TextEditingController(text: widget.userData['sexo'] ?? '');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      // 1. Reautenticar al usuario
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      // 2. Cambiar la contraseña
      await user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
      setState(() => _showPasswordFields = false);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña actual incorrecta';
      } else {
        errorMessage = 'Error: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: ${e.toString()}')),
      );
    }
  }

  void _guardarCambios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
        'nombres': _nombreController.text,
        'apellidos': _apellidoController.text,
        'email': _emailController.text,
        'edad': int.tryParse(_edadController.text) ?? 0,
        'fechaNacimiento': _fechaNacimientoController.text,
        'sexo': _sexoController.text,
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
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
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

            // Sección para cambiar contraseña
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _showPasswordFields = !_showPasswordFields),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
              ),
              child: Text(
                _showPasswordFields
                    ? 'Ocultar cambio de contraseña'
                    : 'Cambiar contraseña',
                style: TextStyle(color: AppColors.primary),
              ),
            ),

            if (_showPasswordFields) ...[
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Contraseña actual',
                obscureText: _obscureCurrentPassword,
                onToggle: () => setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword),
              ),
              const SizedBox(height: 15),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'Nueva contraseña (mínimo 6 caracteres)',
                obscureText: _obscureNewPassword,
                onToggle: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _newPasswordController.text.length >= 6
                      ? _changePassword
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Actualizar contraseña',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],

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
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppColors.secondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.accent,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppColors.secondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.accent,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.highlight),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
