import 'package:flutter/material.dart';
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    word,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (dictResult?.partOfSpeech.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dictResult!.partOfSpeech,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              if (dictResult?.phonetic.isNotEmpty == true)
                Text(
                  dictResult!.phonetic,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.6,
                    ),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        if (dictResult?.audioUrl.isNotEmpty == true)
          IconButton.filledTonal(
            onPressed: () => AudioHelper.playAudio(dictResult!.audioUrl),
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Ses Dinle',
          ),
      ],
    );
  }
}
