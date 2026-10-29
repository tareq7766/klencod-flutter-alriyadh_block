import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _launch(BuildContext context, Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ContactCard(
          icon: Icons.phone, title: 'الهاتف', value: AppConstants.phoneNumber, color: AppColors.primary,
          action: () => _launch(context, Uri(scheme: 'tel', path: AppConstants.phoneNumber)),
          actionLabel: 'اتصال',
        ),
        _ContactCard(
          icon: Icons.chat_bubble, title: 'واتساب', value: AppConstants.phoneNumber, color: AppColors.whatsapp,
          action: () => _launch(context, Uri.parse('https://wa.me/${AppConstants.whatsappNumber}')),
          actionLabel: 'محادثة',
        ),
        _ContactCard(
          icon: Icons.location_on, title: 'العنوان', value: AppConstants.locationText, color: AppColors.accentDark,
          action: () => _launch(context, Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(AppConstants.locationQuery)}')),
          actionLabel: 'الخريطة',
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback action;
  final String actionLabel;

  const _ContactCard({required this.icon, required this.title, required this.value, required this.color, required this.action, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: action, style: ElevatedButton.styleFrom(backgroundColor: color), child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}