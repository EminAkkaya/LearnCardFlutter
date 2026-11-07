import 'package:flutter/material.dart';
import '../../../models/games/speed_quiz_question_model.dart';
import 'game_answer_option.dart';

class SpeedQuizOptionsList extends StatelessWidget {
  final SpeedQuizQuestionModel question;
  final String? selectedOption;
  final bool isAnswered;
  final ValueChanged<String> onOptionSelected;

  const SpeedQuizOptionsList({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.isAnswered,
    required this.onOptionSelected,
  });

  GameOptionState _stateOf(String option) {
    if (!isAnswered) return GameOptionState.idle;
    if (option == question.correctAnswer) return GameOptionState.correct;
    if (option == selectedOption) return GameOptionState.wrong;
    return GameOptionState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.options
          .map(
            (option) => GameAnswerOption(
              text: option,
              state: _stateOf(option),
              onPressed: isAnswered ? null : () => onOptionSelected(option),
            ),
          )
          .toList(),
    );
  }
}
