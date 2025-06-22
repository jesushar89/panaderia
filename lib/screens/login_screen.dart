import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Accede con tu cuenta para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              color: AppColors.textDark, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle:
                                const TextStyle(color: AppColors.secondary),
                            filled: true,
                            fillColor: AppColors.accent,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: AppColors.highlight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                              color: AppColors.textDark, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle:
                                const TextStyle(color: AppColors.secondary),
                            filled: true,
                            fillColor: AppColors.accent,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: AppColors.highlight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _iniciarSesion,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.4),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text(
                            'Continuar como invitado',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            // Lógica de recuperación (puedes implementar la pantalla extra aquí si se requiere)
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // 1. Autenticación con Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. (Opcional) Verificar si el usuario tiene datos en Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // 3. Navegar al home y mostrar datos del usuario
        print('✔ Usuario válido: ${userDoc.data()!['nombres']}');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Caso especial: usuario en Auth pero sin datos en Firestore
        await FirebaseAuth.instance.signOut(); // Cerrar sesión forzada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Datos de usuario no encontrados. Regístrese nuevamente.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Manejo específico de errores de autenticación
      String errorMessage;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Correo o contraseña incorrectos';
      } else {
        errorMessage = 'Error al iniciar sesión: ${e.message}';
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
}
