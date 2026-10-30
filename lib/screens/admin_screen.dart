import 'dart:io';
import 'dart:convert';
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
  String _savedPin = '1234';

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _savedPin = prefs.getString('admin_pin') ?? '1234');
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
    if (!_isAuthenticated) return _buildLoginScreen();
    return _buildDashboard();
  }

  // 1. شاشة الدخول (بدون كشف الرمز)
  Widget _buildLoginScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text('لوحة الإدارة محمية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: InputDecoration(hintText: '----', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkPin,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('دخول', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. لوحة التحكم الرئيسية
  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مرحباً بك يا مدير المصنع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => setState(() => _isAuthenticated = false),
                  icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                  label: const Text('خروج', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _menuCard('إدارة المنتجات', Icons.inventory, () => _openProductManager(context)),
                _menuCard('صور الرئيسية', Icons.photo_library, () => _openImageManager(context, 'home_slider')),
                _menuCard('صور المصنع', Icons.factory, () => _openImageManager(context, 'factory_gallery')),
                _menuCard('تغيير الرمز السري', Icons.password, _showChangePinDialog),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // 3. نافذة تغيير الرمز السري
  void _showChangePinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الرمز السري'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'الرمز الجديد (أرقام فقط)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length >= 4) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('admin_pin', pinController.text);
                setState(() => _savedPin = pinController.text);
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير الرمز بنجاح')));
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // 4. إدارة صور (الرئيسية أو المصنع)
  void _openImageManager(BuildContext context, String type) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ImageManagerScreen(type: type)));
  }

  // 5. إدارة المنتجات
  void _openProductManager(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _ProductsManagerScreen()));
  }
}

// ---------- شاشة إدارة الصور (ديناميكية) ----------
class _ImageManagerScreen extends StatefulWidget {
  final String type;
  const _ImageManagerScreen({required this.type});
  @override
  State<_ImageManagerScreen> createState() => _ImageManagerScreenState();
}

class _ImageManagerScreenState extends State<_ImageManagerScreen> {
  List<String> _images = [];
  final String _key = 'images_${widget.type}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) setState(() => _images = List<String>.from(jsonDecode(raw)));
  }

  Future<void> _add() async {
    final path = await ImageService.pickAndSaveImage();
    if (path != null) {
      setState(() => _images.add(path));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_images));
    }
  }

  Future<void> _delete(int index) async {
    setState(() => _images.removeAt(index));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_images));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.type == 'home_slider' ? 'صور الصفحة الرئيسية' : 'صور المصنع')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add, child: const Icon(Icons.add_a_photo),
      ),
      body: _images.isEmpty
          ? const Center(child: Text('لا توجد صور. اضغط + للإضافة'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1,
              ),
              itemCount: _images.length,
              itemBuilder: (context, i) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_images[i]), fit: BoxFit.cover)),
                    Positioned(
                      top: 5, right: 5,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, shadows: [Shadow(color: Colors.white, blurRadius: 10)]),
                        onPressed: () => _delete(i),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// ---------- شاشة إدارة المنتجات (نفس الكود السابق) ----------
class _ProductsManagerScreen extends StatelessWidget {
  const _ProductsManagerScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المنتجات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const _ProductEditorDialog()),
        icon: const Icon(Icons.add), label: const Text('إضافة منتج'),
      ),
      body: ListenableBuilder(
        listenable: ProductRepository.instance,
        builder: (context, _) {
          final products = ProductRepository.instance.products;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: p.imagePath != null ? Image.file(File(p.imagePath!), width: 50, fit: BoxFit.cover) : const Icon(Icons.image),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p.price != null ? '${p.price} ريال' : 'بدون سعر'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showDialog(context: context, builder: (_) => _ProductEditorDialog(existing: p))),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => ProductRepository.instance.delete(p.id)),
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
              TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              if (_pickedImagePath != null) Image.file(File(_pickedImagePath!), height: 80, fit: BoxFit.cover),
              ElevatedButton.icon(
                onPressed: () async {
                  final path = await ImageService.pickAndSaveImage();
                  if (path != null) setState(() => _pickedImagePath = path);
                },
                icon: const Icon(Icons.image), label: const Text('اختيار صورة'),
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
              name: _name.text, size: _size.text, description: _desc.text,
              price: double.tryParse(_price.text), imagePath: _pickedImagePath,
            );
            if (widget.existing == null) await ProductRepository.instance.add(p);
            else await ProductRepository.instance.update(p);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}