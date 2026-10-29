import 'package:flutter/material.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductRepository.instance,
      builder: (context, _) {
        final repo = ProductRepository.instance;
        if (repo.loading && !repo.loaded) return const Center(child: CircularProgressIndicator());
        if (repo.products.isEmpty) return const Center(child: Text('لا توجد منتجات مضافة حاليًا.'));

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400, mainAxisExtent: 350, crossAxisSpacing: 12, mainAxisSpacing: 12,
          ),
          itemCount: repo.products.length,
          itemBuilder: (context, i) => ProductCard(product: repo.products[i]),
        );
      },
    );
  }
}