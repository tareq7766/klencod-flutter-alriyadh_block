import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        const Text('معرض الصور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: List.generate(4, (i) => Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
          )),
        ),
        const SizedBox(height: 10),
        const Text('سيتم إضافة صور المصنع والمنتجات قريباً.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}