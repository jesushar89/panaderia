import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/colors.dart';
import 'producto_detalle_screen.dart';


class ProductosCategoriaScreen extends StatefulWidget {
  final String categoria;
  const ProductosCategoriaScreen({super.key, required this.categoria});

  @override
  State<ProductosCategoriaScreen> createState() =>
      _ProductosCategoriaScreenState();
}

class _ProductosCategoriaScreenState extends State<ProductosCategoriaScreen> {
  final Map<String, int> cantidades = {};
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  String selectedFilter = 'Sin filtros';

  String _convertDriveUrl(String? url) {
  if (url == null || !url.contains('/')) {
    return 'https://via.placeholder.com/150'; // Imagen por defecto
  }
  final parts = url.split('/');
  if (parts.length > 5) {
    final fileId = parts[5];
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }
  return 'https://via.placeholder.com/150';
}

  void _agregarAlCarrito(Map<String, dynamic> producto) async {
    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final carritoRef = FirebaseFirestore.instance.collection('carrito');
      final existente = await carritoRef
          .where('nombre', isEqualTo: producto['nombre'])
          .limit(1)
          .get();

      if (existente.docs.isNotEmpty) {
        final doc = existente.docs.first;
        final data = doc.data();
        final nuevaCantidad = (data['cantidad'] ?? 1) + 1;
        await doc.reference.update({'cantidad': nuevaCantidad});
      } else {
        await carritoRef.add({
          'nombre': producto['nombre'],
          'precio': producto['precio'],
          'imagen': producto['imagen'],
          'cantidad': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${producto['nombre']} agregado al carrito')),
      );
    } catch (e) {
      print('❌ Error al agregar al carrito: $e');
    }
  }

  void _disminuirCantidad(Map<String, dynamic> producto) async {
    final carritoRef = FirebaseFirestore.instance.collection('carrito');
    final existente = await carritoRef
        .where('nombre', isEqualTo: producto['nombre'])
        .limit(1)
        .get();

    if (existente.docs.isNotEmpty) {
      final doc = existente.docs.first;
      final data = doc.data();
      final nuevaCantidad = (data['cantidad'] ?? 1) - 1;
      if (nuevaCantidad <= 0) {
        await doc.reference.delete();
      } else {
        await doc.reference.update({'cantidad': nuevaCantidad});
      }
    }
  }

  void _mostrarDescripcion(Map<String, dynamic> producto) {
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductoDetalleScreen(producto: producto),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.categoria[0].toUpperCase() + widget.categoria.substring(1),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Nueva barra de búsqueda y filtro: minimalista, sin cajas en bloque, solo líneas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                // Search
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.secondary),
                      filled: true,
                      fillColor: AppColors.accent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.highlight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filtro
                DropdownButtonHideUnderline(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.highlight),
                    ),
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      icon: const Icon(Icons.filter_list,
                          color: AppColors.secondary),
                      items: <String>[
                        'Sin filtros',
                        'Mayor Precio',
                        'Menor Precio',
                        'Más Popular',
                        'Menos Popular',
                        'Ordenar de A a Z',
                        'Ordenar de Z a A'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textDark),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFilter = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de productos en cards minimalistas, con imagen circular y fondo suave
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carrito')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, carritoSnapshot) {
                if (carritoSnapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar el carrito'));
                }
                if (carritoSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final carritoItems = carritoSnapshot.data!.docs;
                for (var item in carritoItems) {
                  final producto = item.data() as Map<String, dynamic>;
                  cantidades[producto['nombre']] = producto['cantidad'];
                }
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('productos')
                      .snapshots(),
                  builder: (context, productosSnapshot) {
                    if (productosSnapshot.hasError) {
                      return const Center(
                          child: Text('Error al cargar productos'));
                    }
                    if (productosSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final todosLosProductos = productosSnapshot.data!.docs;
                    final productosFiltrados = todosLosProductos.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre =
                          data['nombre']?.toString().toLowerCase() ?? '';
                      final coincideBusqueda =
                          searchQuery.isEmpty || nombre.contains(searchQuery);
                      final coincideCategoria = widget.categoria == 'todos' ||
                          data['categoria']?.toString().toLowerCase() ==
                              widget.categoria.toLowerCase();
                      return coincideBusqueda && coincideCategoria;
                    }).toList();
                    // Ordenar
                    if (selectedFilter == 'Ordenar de A a Z') {
                      productosFiltrados.sort((a, b) {
                        final nombreA =
                            (a.data() as Map<String, dynamic>)['nombre']
                                .toString()
                                .toLowerCase();
                        final nombreB =
                            (b.data() as Map<String, dynamic>)['nombre']
                                .toString()
                                .toLowerCase();
                        return nombreA.compareTo(nombreB);
                      });
                    } else if (selectedFilter == 'Ordenar de Z a A') {
                      productosFiltrados.sort((a, b) {
                        final nombreA =
                            (a.data() as Map<String, dynamic>)['nombre']
                                .toString()
                                .toLowerCase();
                        final nombreB =
                            (b.data() as Map<String, dynamic>)['nombre']
                                .toString()
                                .toLowerCase();
                        return nombreB.compareTo(nombreA);
                      });
                    }
                    if (productosFiltrados.isEmpty) {
                      return const Center(
                          child: Text('No se encontraron productos'));
                    }
                    return ListView.separated(
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index].data()
                            as Map<String, dynamic>;
                        final nombre = producto['nombre'];
                        final puntuacion = producto['puntuacion'] ?? 0;
                        cantidades.putIfAbsent(nombre, () => 0);

                        return Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 0),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.highlight, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.08),
                                    blurRadius: 7,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Imagen circular de producto
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                       _convertDriveUrl(producto['imagen'] ?? ''),
                                      ),
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                  ),
                                  const SizedBox(width: 18),
                                  // Info del producto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'S/.${producto['precio']} soles',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.secondary),
                                        ),
                                        Row(
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              i < puntuacion
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: AppColors.highlight,
                                              size: 18,
                                            );
                                          }),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _mostrarDescripcion(producto),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.info_outline,
                                                  size: 18,
                                                  color: AppColors.secondary),
                                              SizedBox(width: 3),
                                              Text('Ver detalles',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          AppColors.secondary,
                                                      decoration: TextDecoration
                                                          .underline)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botones de cantidad
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: AppColors.secondary),
                                        onPressed: () =>
                                            _disminuirCantidad(producto),
                                      ),
                                      Text('${cantidades[nombre] ?? 0}',
                                          style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: AppColors.primary),
                                        onPressed: () =>
                                            _agregarAlCarrito(producto),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
