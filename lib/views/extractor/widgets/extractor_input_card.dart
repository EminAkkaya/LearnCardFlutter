import 'package:flutter/material.dart';

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText:
                'Makale, ders notu veya herhangi bir İngilizce metin yapıştırın...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            filled: true,
          ),
        ),
      ],
    );
  }
}
