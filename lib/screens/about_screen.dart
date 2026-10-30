import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('images_factory_gallery');
    if (raw != null && raw.isNotEmpty) {
      setState(() => _images = List<String>.from(jsonDecode(raw)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('من نحن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                'مصنع الرياض للبلك الأوتوماتيكي هو مصنع متخصص في إنتاج البلك الأسمنتي في صنعاء – المطار – خط العروق. '
                'نعتمد على خطوط إنتاج أوتوماتيكية حديثة ومواد أولية عالية الجودة لنقدم بلكًا قويًا ومتينًا يلبي احتياجات البناء بمختلف أنواعه.',
                style: TextStyle(fontSize: 14, height: 1.7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('معرض صور المصنع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (_images.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Text('سيتم إضافة صور المصنع قريباً من قبل الإدارة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(_images[index]), fit: BoxFit.cover));
            },
          ),
      ],
    );
  }
}