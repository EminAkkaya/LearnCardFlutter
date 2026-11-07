import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';

class ExtractorInputCard extends StatelessWidget {
  final TextEditingController controller;

  const ExtractorInputCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İngilizce Metin Yapıştırın',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPalette.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText:
                'Makale, ders notu veya herhangi bir İngilizce metin yapıştırın...',
          ),
        ),
      ],
    );
  }
}
