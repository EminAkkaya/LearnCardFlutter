import 'package:flutter/material.dart';

class AppInfoCard extends StatelessWidget {
  final Color primaryColor;

  const AppInfoCard({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.touch_app_rounded, color: primaryColor),
            ),
            title: const Text('Uygulama Adı'),
            subtitle: const Text('LearnCard Mobile'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.vibration_rounded, color: primaryColor),
            ),
            title: const Text('Versiyon'),
            subtitle: const Text('1.0.0+1'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.cloud_done_rounded, color: primaryColor),
            ),
            title: const Text('Veri Senkronizasyonu'),
            subtitle: const Text('Supabase Cloud + Drift SQLite'),
          ),
        ],
      ),
    );
  }
}
