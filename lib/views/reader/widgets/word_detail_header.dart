import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../services/dictionary_service.dart';

class WordDetailHeader extends StatelessWidget {
  final String word;
  final WordDefinitionResult? dictResult;

  const WordDetailHeader({
    super.key,
    required this.word,
    required this.dictResult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Ana kelime sayfadaki tek gerçek vurgu: büyük ve vurgu renginde.
                  Text(
                    word,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (dictResult?.partOfSpeech.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.subtle,
                        borderRadius: BorderRadius.circular(AppPalette.radiusPill),
                        border: Border.all(color: palette.border),
                      ),
                      child: Text(
                        dictResult!.partOfSpeech,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              if (dictResult?.phonetic.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    dictResult!.phonetic,
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (dictResult?.audioUrl.isNotEmpty == true)
          IconButton.outlined(
            onPressed: () => AudioHelper.playAudio(dictResult!.audioUrl),
            icon: const Icon(LucideIcons.volume2, size: 20),
            tooltip: 'Ses Dinle',
            style: IconButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.controlBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppPalette.radiusControl),
              ),
            ),
          ),
      ],
    );
  }
}
