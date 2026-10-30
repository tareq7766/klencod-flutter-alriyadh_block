import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/product_repository.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isAuthenticated = false;
  final TextEditingController _pinController = TextEditingController();
  String _savedPin = '1234'; // الرمز الافتراضي

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('admin_pin') ?? '1234';
    });
  }

  void _checkPin() {
    if (_pinController.text == _savedPin) {
      setState(() {
        _isAuthenticated = true;
        _pinController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز المرور غير صحيح!'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return _buildLoginScreen();
    }
    return _buildAdminPanel();
  }

  // شاشة القفل
  Widget _buildLoginScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'لوحة الإدارة محمية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              'أدخل الرمز السري للدخول\n(الرمز الافتراضي: 1234)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: InputDecoration(
                hintText: '----',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('دخول', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // لوحة الإدارة (نفس الكود السابق مع إضافة زر تسجيل الخروج)
  Widget _buildAdminPanel() {
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
                      leading: p.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover))
                          : const Icon(Icons.image, size: 40),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.size} | ${p.price != null ? "${p.price} ريال" : "بدون سعر"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEditor(context, existing: p)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(context, p)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: const Color(0xFFC62828), // لون أحمر ليدل على وضع المدير
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('أنت في وضع المدير', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => setState(() => _isAuthenticated = false),
                      child: const Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('خروج', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${p.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ProductRepository.instance.delete(p.id);
    }
  }

  void _openEditor(BuildContext context, {Product? existing}) async {
    await showDialog(
      context: context,
      builder: (_) => _ProductEditorDialog(existing: existing),
    );
  }
}

// نافذة إضافة وتعديل المنتج (بدون تغيير)
class _ProductEditorDialog extends StatefulWidget {
  final Product? existing;
  const _ProductEditorDialog({this.existing});
  @override
  State<_ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<_ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _size, _desc, _price;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _size = TextEditingController(text: widget.existing?.size ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
    _price = TextEditingController(text: widget.existing?.price?.toString() ?? '');
    _pickedImagePath = widget.existing?.imagePath;
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
              const SizedBox(height: 15),
              if (_pickedImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_pickedImagePath!), height: 80, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final path = await ImageService.pickAndSaveImage();
                  if (path != null) {
                    setState(() => _pickedImagePath = path);
                  }
                },
                icon: const Icon(Icons.image),
                label: Text(_pickedImagePath == null ? 'إضافة صورة من المعرض' : 'تغيير الصورة'),
              ),
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
              imagePath: _pickedImagePath,
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