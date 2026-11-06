import 'package:flutter/material.dart';
import 'cloze_question_model.dart';

class ClozeOptionsList extends StatelessWidget {
  final ClozeQuestionModel question;
  final String? selectedOption;
  final bool isAnswered;
  final ValueChanged<String> onOptionSelected;

  static const Color emerald = Color(0xFF10B981);

  const ClozeOptionsList({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.isAnswered,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: question.options.map((option) {
        Color btnColor = theme.colorScheme.surface;
        Color borderColor = theme.dividerColor.withValues(alpha: 0.5);
        Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

        if (isAnswered) {
          if (option.toLowerCase() == question.correctWord.toLowerCase()) {
            btnColor = emerald.withValues(alpha: 0.2);
            borderColor = emerald;
            textColor = emerald;
          } else if (option == selectedOption) {
            btnColor = Colors.redAccent.withValues(alpha: 0.2);
            borderColor = Colors.redAccent;
            textColor = Colors.redAccent;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAnswered ? null : () => onOptionSelected(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: textColor,
                elevation: 1,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: borderColor,
                    width: (isAnswered && (option.toLowerCase() == question.correctWord.toLowerCase() || option == selectedOption)) ? 2 : 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isAnswered && option.toLowerCase() == question.correctWord.toLowerCase())
                    const Icon(Icons.check_circle_rounded, color: emerald, size: 20)
                  else if (isAnswered && option == selectedOption)
                    const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
