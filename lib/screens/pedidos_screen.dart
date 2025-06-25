import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Debes iniciar sesión para ver tus pedidos'));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los pedidos'));
          }

          final pedidos = snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, color: AppColors.primary, size: 70),
                  SizedBox(height: 20),
                  Text(
                    'Aún no tienes pedidos registrados',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '¡Tus compras aparecerán aquí!',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: pedidos.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = pedidos[index].data() as Map<String, dynamic>;
              final productos = data['productos'] as List<dynamic>;
              final estado = data['estado'] ?? 'Pendiente';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🧾 Pedido #${pedidos.length - index}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          )),
                      const SizedBox(height: 8),
                      ...productos.map((prod) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  _convertDriveUrl(prod['imagen']),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported, size: 40),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('${prod['nombre']} x${prod['cantidad']}',
                                    style: const TextStyle(fontSize: 14)),
                              ),
                              Text('S/.${prod['precio']}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      Text('Estado: $estado',
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _convertDriveUrl(String urlOrId) {
  // Si el valor ya es una URL de imagen directa (ej: jpg/png), lo dejamos
  if (urlOrId.contains('https://') && (urlOrId.contains('.jpg') || urlOrId.contains('.png'))) {
    return urlOrId;
  }

  // Si es solo el ID de Google Drive
  if (!urlOrId.contains('https://')) {
    return 'https://drive.google.com/uc?export=view&id=$urlOrId';
  }

  // Si es un link completo de Google Drive, extraemos el ID
  final RegExp regex = RegExp(r'd/([a-zA-Z0-9_-]+)');
  final match = regex.firstMatch(urlOrId);
  if (match != null) {
    final id = match.group(1);
    return 'https://drive.google.com/uc?export=view&id=$id';
  }

  // Si nada funcionó, devolvemos una imagen por defecto
  return 'https://via.placeholder.com/150';
}


}