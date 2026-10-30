import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // تم تعديل الامتداد هنا ليكون jpg ليتطابق مع صورك
  final List<String> _images = [
    'assets/factory1.jpg',
    'assets/factory2.jpg',
    'assets/factory3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
          // 1. شريط الصور المتحرك
          SizedBox(
            height: 220, // زيادة الارتفاع قليلاً لتبدو الصور أجمل
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      // في حال لم يتم رفع الصورة أو كان الاسم خطأ، تظهر خلفية رمادية بدلاً من خطأ
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryDark,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                              SizedBox(height: 8),
                              Text('الصورة غير متوفرة', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // النقاط السفلية للدلالة على الصفحة الحالية
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.accent : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. الكارت الرئيسي (الشعار والأزرار)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.factory,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مصنع الرياض',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text('للبلك الأوتوماتيكي',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('بلك قوي ومتين، جودة تعتمد عليها',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('صنعاء – المطار – خط العروق',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launch(context,
                            Uri(scheme: 'tel', path: AppConstants.phoneNumber)),
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text('اتصال'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launch(context,
                            Uri.parse('https://wa.me/${AppConstants.whatsappNumber}')),
                        icon: const Icon(Icons.chat_bubble, size: 20),
                        label: const Text('واتساب'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsapp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 3. المميزات
          const SectionHeader(
              title: 'مميزاتنا',
              subtitle: 'لماذا يختارنا البناؤون؟',
              icon: Icons.verified),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _FeatureItem(
                    icon: Icons.precision_manufacturing,
                    title: 'إنتاج أوتوماتيكي',
                    desc: 'خطوط إنتاج حديثة تضمن دقة المقاسات'),
                _FeatureItem(
                    icon: Icons.shield,
                    title: 'متانة عالية',
                    desc: 'مواد أولية ممتازة تتحمل الظروف الصعبة'),
                _FeatureItem(
                    icon: Icons.verified_user,
                    title: 'جودة مضمونة',
                    desc: 'إسمنت عالي الجودة وتجانس في الخلطة'),
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
  const _FeatureItem(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}