import 'package:flutter/material.dart';
import '../../../providers/flashcard_provider.dart';
import 'custom_study_sheet_content.dart';

void showCustomStudyBottomSheet(
  BuildContext context,
  FlashcardState cardState, {
  String initialStatus = 'all',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => CustomStudySheetContent(
      cardState: cardState,
      initialStatus: initialStatus,
    ),
  );
}
