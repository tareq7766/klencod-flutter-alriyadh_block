import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _imageWidget(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.straighten, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(product.size, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, height: 1.35)),
                  ),
                  const SizedBox(height: 8),
                  _priceChip(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageWidget() {
    final url = product.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Center(child: Icon(Icons.view_in_ar, size: 48, color: AppColors.textSecondary)),
    );
  }

  Widget _priceChip() {
    if (product.price != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.accent.withAlpha(31), borderRadius: BorderRadius.circular(8)),
        child: Text('السعر: ${product.price!.toStringAsFixed(0)} ريال',
            style: const TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.bold, fontSize: 13)),
      );
    }
    return const Text('السعر عند الطلب',
        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic));
  }
}