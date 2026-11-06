import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../models/games/cloze_question_model.dart';

class ClozeOptionsList extends StatelessWidget {
  final ClozeQuestionModel question;
  final String? selectedOption;
  final bool isAnswered;
  final ValueChanged<String> onOptionSelected;

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
    final fb = FeedbackColors.of(context);

    return Column(
      children: question.options.map((option) {
        Color btnColor = theme.colorScheme.surface;
        Color borderColor = theme.dividerColor.withValues(alpha: 0.5);
        Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

        if (isAnswered) {
          if (option.toLowerCase() == question.correctWord.toLowerCase()) {
            btnColor = fb.success.withValues(alpha: 0.2);
            borderColor = fb.success;
            textColor = fb.success;
          } else if (option == selectedOption) {
            btnColor = fb.danger.withValues(alpha: 0.2);
            borderColor = fb.danger;
            textColor = fb.danger;
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
                    Icon(Icons.check_circle_rounded, color: fb.success, size: 20)
                  else if (isAnswered && option == selectedOption)
                    Icon(Icons.cancel_rounded, color: fb.danger, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
