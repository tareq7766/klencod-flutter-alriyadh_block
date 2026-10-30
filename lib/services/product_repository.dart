import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductRepository extends ChangeNotifier {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();

  static const String _storageKey = 'products_v1';

  List<Product> _products = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  Future<void> init() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        _products = _defaults();
        await _persist();
      } else {
        final list = (jsonDecode(raw) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList();
        _products = list;
      }
      _loaded = true;
      _error = null;
    } catch (e) {
      _products = _defaults();
      _loaded = true;
      _error = 'تعذر تحميل البيانات: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Product p) async {
    _products = [..._products, p];
    await _persist();
    notifyListeners();
  }

  Future<void> update(Product p) async {
    _products = _products.map((e) => e.id == p.id ? p : e).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _products = _products.where((e) => e.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_products.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      _error = 'تعذر حفظ البيانات: $e';
      notifyListeners();
    }
  }

  List<Product> _defaults() => [
        const Product(
          id: 'b20_solid',
          name: 'بلك أبو عشرين صم (مصمت)',
          size: '20 × 20 × 40 سم',
          description: 'بلك مصمت (صم) مقاس 20، يستخدم للجدران الحاملة، القواعد، والأسوار. قوة تحمل عالية جداً.',
        ),
        const Product(
          id: 'b20_hollow_heavy',
          name: 'بلك أبو عشرين مخرق ثقيل',
          size: '20 × 20 × 40 سم',
          description: 'بلك مفرغ (مخرق) ثقيل مقاس 20، وزن عالي وقوة تحمل ممتازة، مناسب للجدران الخارجية والحاملة.',
        ),
        const Product(
          id: 'b20_hollow_light',
          name: 'بلك أبو عشرين مخرق خفيف',
          size: '20 × 20 × 40 سم',
          description: 'بلك مفرغ (مخرق) خفيف مقاس 20، يقلل الوزن على الهيكل الخرساني ويوفر في التكلفة، ممتاز للجدران الخارجية العادية.',
        ),
        const Product(
          id: 'b15_solid',
          name: 'بلك أبو 15 صم (مصمت)',
          size: '15 × 20 × 40 سم',
          description: 'بلك مصمت (صم) مقاس 15، مثالي للقواطع الداخلية والأسوار الخفيفة التي تحتاج قوة تحمل.',
        ),
        const Product(
          id: 'b15_hollow',
          name: 'بلك أبو 15 مخرق (ثقيل / خفيف)',
          size: '15 × 20 × 40 سم',
          description: 'بلك مفرغ (مخرق) مقاس 15 (متوفر ثقيل وخفيف)، يستخدم للقواطع الداخلية وتقسيم الغرف، جودة عالية وسهولة في البناء.',
        ),
      ];
}