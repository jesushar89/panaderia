import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  String _convertDriveUrl(String url) {
    final fileId = url.split('/')[5];
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = producto['nombre'] ?? 'Sin nombre';
    final String descripcion = producto['descripcion'] ?? 'Sin descripción';
    final double precio = producto['precio']?.toDouble() ?? 0.0;
    final int puntuacion = producto['puntuacion'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(_convertDriveUrl(producto['imagen'])),
                radius: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'S/. $precio soles',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < puntuacion ? Icons.star : Icons.star_border,
                  color: AppColors.highlight,
                );
              }),
            ),
            const SizedBox(height: 10),
            const Text(
              'Descripción:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(descripcion),
          ],
        ),
      ),
    );
  }
}
