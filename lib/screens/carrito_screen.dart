import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  _CarritoScreenState createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  String tipoEntrega = 'Recoger en tienda';
  double costoEnvio = 0.0;

  void _actualizarCantidad(DocumentReference ref, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await ref.delete();
    } else {
      await ref.update({'cantidad': nuevaCantidad});
    }
  }

void _confirmarPedido(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final carritoSnapshot = await FirebaseFirestore.instance
      .collection('carrito')
      .where('userId', isEqualTo: user.uid)
      .get();

  if (carritoSnapshot.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu carrito está vacío')),
    );
    return;
  }

  List<Map<String, dynamic>> productos = [];

  for (var doc in carritoSnapshot.docs) {
    final data = doc.data();
    productos.add({
      'nombre': data['nombre'],
      'precio': data['precio'],
      'cantidad': data['cantidad'],
      'imagen': data['imagen'],
    });
  }

  await FirebaseFirestore.instance.collection('pedidos').add({
    'userId': user.uid,
    'productos': productos,
    'estado': 'Pendiente',
    'tipoEntrega': tipoEntrega,
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Borra el carrito después de confirmar
  for (var doc in carritoSnapshot.docs) {
    await doc.reference.delete();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ Pedido confirmado')),
  );
}

  String _convertDriveUrl(String? url) {
  if (url == null || !url.contains('/')) {
    return 'https://via.placeholder.com/100'; // Imagen temporal si no hay válida
  }

  final parts = url.split('/');
  if (parts.length > 5) {
    final fileId = parts[5];
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }

  return 'https://via.placeholder.com/100';
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carrito')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el carrito'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.primary),
                  const SizedBox(height: 18),
                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Agrega productos para continuar',
                    style: TextStyle(fontSize: 15, color: AppColors.secondary),
                  ),
                ],
              ),
            );
          }

          double total = 0;
          double totalIGV = 0;

          for (var doc in items) {
            final data = doc.data() as Map<String, dynamic>;
            final precioFinal = data['precio'] ?? 0;
            final cantidad = data['cantidad'] ?? 1;
            final precioBase = precioFinal / 1.18;
            final igvProducto = precioBase * 0.18;
            total += precioFinal * cantidad;
            totalIGV += igvProducto * cantidad;
          }

          if (tipoEntrega == 'Envío') {
            costoEnvio = 5.0;
          } else {
            costoEnvio = 0.0;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final producto = doc.data() as Map<String, dynamic>;
                    final precioFinal = producto['precio'] ?? 0;
                    final cantidad = producto['cantidad'] ?? 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.highlight, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 7,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _convertDriveUrl(producto['imagen']),
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 46, color: Colors.grey);
                            },
                          ),
                        ),

                        title: Text(
                          producto['nombre'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        subtitle: Text(
                          'S/.${precioFinal.toStringAsFixed(2)} x $cantidad',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.secondary),
                              onPressed: () => _actualizarCantidad(doc.reference, cantidad - 1),
                            ),
                            Text('$cantidad', style: const TextStyle(fontSize: 15)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                              onPressed: () => _actualizarCantidad(doc.reference, cantidad + 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Opción de Envío o Recogida
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                child: Column(
                  children: [
                    const Text(
                      'Selecciona la opción de entrega:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _deliveryOption('Recoger en tienda', tipoEntrega == 'Recoger en tienda', () {
                          setState(() => tipoEntrega = 'Recoger en tienda');
                        }),
                        const SizedBox(width: 18),
                        _deliveryOption('Envío (S/. 5.00)', tipoEntrega == 'Envío', () {
                          setState(() => tipoEntrega = 'Envío');
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Resumen de totales
              _resumenItem('Total (sin IGV):', (total - totalIGV)),
              _resumenItem('IGV (18%):', totalIGV),
              _resumenItem('Envío:', costoEnvio),
              _resumenItem('Total a Pagar:', total + costoEnvio, highlight: true),
              // Botón de Confirmación de Pedido
              Padding(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _confirmarPedido(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.primary, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Pedido',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _deliveryOption(String text, bool selected, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : AppColors.accent,
        foregroundColor: selected ? Colors.white : AppColors.primary,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.highlight, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _resumenItem(String label, double valor, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? AppColors.primary : AppColors.textDark,
            ),
          ),
          Text(
            'S/.${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}