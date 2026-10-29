import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _launch(BuildContext context, Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
      }
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topRight, end: Alignment.bottomLeft),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.factory, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مصنع الرياض', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('للبلك الأوتوماتيكي', style: TextStyle(color: Colors.white70, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('بلك قوي ومتين، جودة تعتمد عليها', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('صنعاء – المطار – خط العروق', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launch(context, Uri(scheme: 'tel', path: AppConstants.phoneNumber)),
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text('اتصال'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launch(context, Uri.parse('https://wa.me/${AppConstants.whatsappNumber}')),
                        icon: const Icon(Icons.chat_bubble, size: 20),
                        label: const Text('واتساب'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.whatsapp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'مميزاتنا', subtitle: 'لماذا يختارنا البناؤون؟', icon: Icons.verified),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _FeatureItem(icon: Icons.precision_manufacturing, title: 'إنتاج أوتوماتيكي', desc: 'خطوط إنتاج حديثة تضمن دقة المقاسات'),
                _FeatureItem(icon: Icons.shield, title: 'متانة عالية', desc: 'مواد أولية ممتازة تتحمل الظروف الصعبة'),
                _FeatureItem(icon: Icons.verified_user, title: 'جودة مضمونة', desc: 'إسمنت عالي الجودة وتجانس في الخلطة'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}