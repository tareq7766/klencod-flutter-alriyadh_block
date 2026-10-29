import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_repository.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductRepository.instance,
      builder: (context, _) {
        final products = ProductRepository.instance.products;
        return Stack(
          children: [
            if (products.isEmpty)
              const Center(child: Text('لا توجد منتجات. اضغط + للإضافة.'))
            else
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 40, 12, 96),
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.size} | ${p.price != null ? "${p.price} ريال" : "بدون سعر"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openEditor(context, existing: p)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(context, p)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: const Color(0xFFFFF3CD),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Text('تنبيه: هذه اللوحة غير محمية. أي شخص يمكنه التعديل.', style: TextStyle(fontSize: 11, color: Color(0xFF8A6D3B))),
              ),
            ),
            Positioned(
              bottom: 20, left: 20,
              child: FloatingActionButton.extended(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _delete(BuildContext context, Product p) async {
    await ProductRepository.instance.delete(p.id);
  }

  void _openEditor(BuildContext context, {Product? existing}) async {
    await showDialog(
      context: context,
      builder: (_) => _ProductEditorDialog(existing: existing),
    );
  }
}

class _ProductEditorDialog extends StatefulWidget {
  final Product? existing;
  const _ProductEditorDialog({this.existing});
  @override
  State<_ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<_ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _size, _desc, _price;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _size = TextEditingController(text: widget.existing?.size ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
    _price = TextEditingController(text: widget.existing?.price?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'إضافة منتج' : 'تعديل منتج'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم'), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              TextFormField(controller: _size, decoration: const InputDecoration(labelText: 'المقاس'), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 2, validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'السعر (اختياري)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final p = Product(
              id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: _name.text,
              size: _size.text,
              description: _desc.text,
              price: double.tryParse(_price.text),
            );
            if (widget.existing == null) {
              await ProductRepository.instance.add(p);
            } else {
              await ProductRepository.instance.update(p);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}