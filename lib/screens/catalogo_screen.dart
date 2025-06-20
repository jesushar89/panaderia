import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'productos_categoria_screen.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  static final List<_Categoria> categorias = [
    _Categoria('Panes', '🥖', AppColors.primary),
    _Categoria('Pasteles', '🍰', AppColors.secondary),
    _Categoria('Tortas', '🎂', AppColors.highlight),
    _Categoria('Bizcochos', '🍪', AppColors.button),
    _Categoria('Pies', '🥧', AppColors.accent),
    _Categoria('Todos los productos', '🛍️', Colors.brown),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explora por categoría',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          // Grid estilo barra de chocolate
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 1, // Cuadrados
              children: categorias.map((cat) {
                return _ChocolateTile(
                  titulo: cat.titulo,
                  emoji: cat.emoji,
                  color: cat.color,
                  onTap: () {
                    String key = cat.titulo.toLowerCase();
                    if (cat.titulo == 'Todos los productos') key = 'todos';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductosCategoriaScreen(categoria: key),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChocolateTile extends StatelessWidget {
  final String titulo;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  const _ChocolateTile({
    required this.titulo,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6B4F29),
                const Color(0xFF8D5524),
                const Color(0xFFD2B48C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.11),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            // Simula líneas de chocolate
            border: Border.all(color: Colors.brown.shade700, width: 2),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 3,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Opcional: líneas separadoras para simular barra
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (_, constraints) => Column(
                    children: List.generate(3, (i) {
                      if (i == 0) return const SizedBox();
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.13),
                        height: 2,
                        color: Colors.brown.shade800.withOpacity(0.25),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Categoria {
  final String titulo;
  final String emoji;
  final Color color;
  const _Categoria(this.titulo, this.emoji, this.color);
}